import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/paths.dart';
import 'package:watcher/watcher.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';

part 'app_repoository_impl_utils.dart';

class AppRepositoryImpl implements AppRepository {
  final _lookupTable = <String, EncryptedFolder>{};
  final _streamManagers = <String, StreamManager>{};

  @override
  Future<void> dispose() async {
    for (final sm in _streamManagers.values) {
      await sm.dispose();
    }
    _streamManagers.clear();
  }

  /// Returns the root folder for the Encrypted Directory with all subfolders and images fully scanned and populated.
  /// If the root folder doesn't exist, it will be created and then be returned
  @override
  Future<EncryptedFolder> loadPrivateRootFolder() async {
    final appPath = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory(
      '${appPath.path}${Platform.pathSeparator}encrypted',
    );
    final encryptedExists = await encryptedDir.exists();
    if (!encryptedExists) {
      await encryptedDir.create(recursive: true);
    }

    final rootFolder = await _scanFullFolderPrivate(encryptedDir.path);
    _lookupTable.addAll(_buildFolderIndex(rootFolder));
    return rootFolder;
  }

  /// Returns the root folder for the Public Encrypted Directory with all subfolders and images fully scanned and populated.
  /// If the root folder doesn't exist, it will be created and then be returned. If creation fails (e.g. due to permissions), null is returned.
  /// On iOS, if the folder exists but is currently inaccessible (e.g. it's a virtual album),
  /// an empty root folder with the correct path is returned so that watchFolderChanges
  /// can be attached and detect when it becomes accessible.
  @override
  Future<EncryptedFolder?> loadPublicRootFolder() async {
    final assets = await GalleryPathProvider.getImagesFromPublicGallery();

    if (assets.isEmpty) {
      // Folder may exist but have no images yet (just created).
      // Return an empty root so watchFolderChanges can be attached.
      final path = await GalleryPathProvider.getPublicFolderPath();

      if (path == null || path.trim().isEmpty) return null;
      if (!Platform.isIOS && !await Directory(path).exists()) return null;

      final emptyFolder = EncryptedFolder.empty(path, false);
      _lookupTable.addAll(_buildFolderIndex(emptyFolder));
      return emptyFolder;
    }

    final rootFolder = await _scanFullFolderPublic(assets);
    _lookupTable.addAll(_buildFolderIndex(rootFolder));
    return rootFolder;
  }

  @override
  Stream<void> watchFolderChanges(EncryptedFolder rootFolder) async* {
    if (rootFolder.path.trim().isEmpty) {
      appLogger.logPageBloc('Skipping folder watcher: empty folder path');
      return;
    }

    if (!rootFolder.isPrivateFolder &&
        Platform.isIOS &&
        GalleryPathProvider.isIosVirtualGalleryPath(rootFolder.path)) {
      appLogger.logPageBloc(
        'Skipping iOS public watcher: virtual album path (${rootFolder.path})',
      );
      return;
    }

    final encryptedDir = Directory(rootFolder.path);
    if (!await encryptedDir.exists()) {
      appLogger.logPageBloc(
        'Skipping folder watcher: folder does not exist (${rootFolder.path})',
      );
      return;
    }

    // On macOS/iOS, /var is a symlink to /private/var. FSEvents always delivers
    // resolved paths, but stored paths use the original (unresolved) form.
    // Resolve the root once and strip the resolved prefix from incoming events
    // so all lookups and stored paths remain consistent.
    String resolvedRoot;
    try {
      resolvedRoot = await encryptedDir.resolveSymbolicLinks();
    } on FileSystemException {
      resolvedRoot = rootFolder.path;
    }
    final originalRoot = rootFolder.path;

    String normalizePath(String p) {
      if (originalRoot != resolvedRoot && p.startsWith(resolvedRoot)) {
        return originalRoot + p.substring(resolvedRoot.length);
      }
      return p;
    }

    await _streamManagers[rootFolder.path]?.dispose();
    final watcher = DirectoryWatcher(encryptedDir.path);
    final sm = StreamManager.fromStream(watcher.events);
    _streamManagers[rootFolder.path] = sm;

    // Wait for the watcher to finish its initialization window (the watcher
    // package intentionally discards all events until ready to filter out
    // spurious OS events that predate the watch start).
    await watcher.ready;

    final pendingRemovals = <String, DateTime>{};
    const removeCoalesceWindow = Duration(milliseconds: 700);

    final mergedController = StreamController<WatchEvent?>();

    // Schedules a one-shot null pulse into mergedController after the coalesce
    // window expires. Only called when a removal is queued, so no timer runs
    // when pendingRemovals is empty.
    void schedulePendingFlush() {
      Future.delayed(
        removeCoalesceWindow + const Duration(milliseconds: 50),
        () {
          if (!mergedController.isClosed) mergedController.add(null);
        },
      );
    }

    final fsSub = sm.stream.listen(
      (e) {
        if (!mergedController.isClosed) mergedController.add(e);
      },
      onDone: () => mergedController.close(),
      onError: (Object e, StackTrace s) {
        if (!mergedController.isClosed) mergedController.addError(e, s);
      },
    );

    try {
      await for (final event in mergedController.stream) {
        final flushed = _flushExpiredRemovals(
          rootFolder: rootFolder,
          pendingRemovals: pendingRemovals,
          window: removeCoalesceWindow,
        );
        if (flushed) {
          yield null;
        }

        // Delayed flush pulse — only used to drive the flush above.
        if (event == null) continue;

        if (event.type != ChangeType.ADD &&
            event.type != ChangeType.REMOVE &&
            event.type != ChangeType.MODIFY) {
          continue;
        }

        final path = normalizePath(event.path);

        if (event.type == ChangeType.MODIFY) {
          continue;
        }

        if (event.type == ChangeType.REMOVE) {
          // Watcher reports rename/move as REMOVE + ADD. Delay remove briefly
          // so we can coalesce the pair and treat it as a move.
          pendingRemovals[path] = DateTime.now();
          // Schedule a one-shot flush after the coalesce window so the removal
          // is processed even if no further FS events arrive.
          schedulePendingFlush();
          continue;
        }

        final movedFrom = _takeMoveSourceCandidate(pendingRemovals, path);
        if (movedFrom != null) {
          final moved = await _applyMovePath(
            rootFolder: rootFolder,
            fromPath: movedFrom,
            toPath: path,
            rootPath: originalRoot,
          );
          if (moved) {
            yield null;
            continue;
          }

          // Fall back to normal remove+add behavior if this wasn't a true move.
          _applyRemovePath(rootFolder, movedFrom);
        }

        final isDirectory =
            Directory(path).existsSync() || !path.split('/').last.contains('.');
        if (isDirectory) {
          final newFolder = await _scanFullFolderPrivate(path);

          final inserted = insertFolderFast(
            rootFolder: rootFolder,
            newFolder: newFolder,
          );

          if (inserted) {
            // Keep the lookup table in sync so future delete events can find
            // this folder (and any nested subfolders it may contain).
            _lookupTable.addAll(_buildFolderIndex(newFolder));
            yield null;
          }
          continue;
        }

        final parentPath = Directory(path).parent.path;
        EncryptedFolder? parentFolder = _lookupTable[parentPath];
        if (parentFolder == null) {
          final recovered = await _recoverMissingParentFolder(
            rootFolder: rootFolder,
            parentPath: parentPath,
            rootPath: originalRoot,
          );
          if (recovered) {
            parentFolder = _lookupTable[parentPath];
          }
        }

        if (parentFolder == null) {
          appLogger.logPageBloc(
            'Failed to add new file',
            error: 'Parent folder not found in lookup for path: $path',
          );
          continue;
        }

        final file = File(path);
        // On macOS, FSEvents fires a spurious CREATE event for a file that is
        // concurrently being deleted (race condition). Skip gracefully so the
        // subsequent DELETE event can handle the removal correctly.
        if (!file.existsSync()) continue;

        final date = file.statSync().modified;
        final bytes = await file.readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        final newImage = EncryptedImage(
          storagePath: StoragePath(
            path: path,
            isPrivateFolder: rootFolder.isPrivateFolder,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
          date: date,
        );

        // On macOS, FSEvents fires spurious CREATE events for already-existing
        // files when the watcher first starts (initial state replay). Only
        // notify listeners when the image is genuinely new to avoid triggering
        // a UI refresh for these no-op resync events.
        final wasPresent = parentFolder.images.any(
          (img) => img.storagePath.path == path,
        );
        parentFolder.images.removeWhere((img) => img.storagePath.path == path);
        parentFolder.images.add(newImage);
        if (!wasPresent) {
          yield null;
        }
      }

      if (pendingRemovals.isNotEmpty) {
        for (final path in pendingRemovals.keys.toList()) {
          _applyRemovePath(rootFolder, path);
        }
      }
    } finally {
      await fsSub.cancel();
      await mergedController.close();
      await _streamManagers[rootFolder.path]?.dispose();
      _streamManagers.remove(rootFolder.path);
    }
  }

  @override
  Future<bool> createPublicFolder() async {
    try {
      final publicAsset = await GalleryPathProvider.getPublicFolder(
        requestIfNeeded: true,
      );
      if (publicAsset != null) return true;

      if (Platform.isIOS || Platform.isMacOS) {
        final album = await PhotoManager.editor.darwin.createAlbum(
          Constants.appFolderName,
        );
        return album != null;
      }

      if (Platform.isAndroid) {
        final path = await GalleryPathProvider.getPublicFolderPath();
        if (path == null) return false;
        await Directory(path).create(recursive: true);
        return true;
      }

      return true;
    } catch (e) {
      appLogger.logUsecase('Error creating public folder', error: e.toString());
      return false;
    }
  }

  @override
  Future<List<GalleryImage>> mapAssetsToGalleryImages(
    List<AssetEntity> assets,
  ) async {
    final List<GalleryImage> images = [];

    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        final rawId = asset.id;
        final cleanId =
            rawId.contains('.')
                ? rawId.substring(0, rawId.lastIndexOf('.'))
                : rawId;
        images.add(
          GalleryImage(id: cleanId, file: file, date: asset.createDateTime),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error mapping asset to GalleryImage',
          error: e.toString(),
        );
      }
    }

    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }
}
