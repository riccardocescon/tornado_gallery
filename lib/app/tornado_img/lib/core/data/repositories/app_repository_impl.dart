import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
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

  @override
  Future<EncryptedFolder> loadRootFolder() async {
    final appPath = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appPath.path}/encrypted');
    final encryptedExists = await encryptedDir.exists();
    if (!encryptedExists) {
      await encryptedDir.create(recursive: true);
    }

    final rootFolder = await _scanFullFolderPrivate(encryptedDir.path);
    _lookupTable.addAll(_buildFolderIndex(rootFolder));
    return rootFolder;
  }

  @override
  Future<EncryptedFolder?> loadPublicRootFolder() async {
    final assets = await GalleryPathProvider.getImagesFromPublicGallery();

    if (assets.isEmpty) {
      // Folder may exist but have no images yet (just created).
      // Return an empty root so watchFolderChanges can be attached.
      final path = await GalleryPathProvider.getPublicFolderPath();
      if (path == null || path.trim().isEmpty) return null;
      if (!await Directory(path).exists()) return null;
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

    final encryptedDir = Directory(rootFolder.path);
    if (!await encryptedDir.exists()) {
      appLogger.logPageBloc(
        'Skipping folder watcher: folder does not exist (${rootFolder.path})',
      );
      return;
    }

    final folderStream = DirectoryWatcher(encryptedDir.path).events;

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
    final sm = StreamManager.fromStream(folderStream);
    _streamManagers[rootFolder.path] = sm;

    try {
      await for (final event in sm.stream) {
        if (event.type != ChangeType.ADD && event.type != ChangeType.REMOVE) {
          continue;
        }

        final path = normalizePath(event.path);
        appLogger.logPageBloc(
          "Received file system event: ${event.toString()}",
        );

        if (event.type == ChangeType.REMOVE) {
          // On macOS, event.isDirectory is unreliable for delete events because
          // the file no longer exists. Use the lookup table instead: if the
          // path is a known folder, treat it as a folder delete; otherwise
          // treat it as a file delete and look up the parent folder.
          final folder = _lookupTable[path];
          if (folder != null) {
            _removeEncryptedFolder(rootFolder, folder);
            _lookupTable.remove(path);
            appLogger.logPageBloc(
              'Folder deleted: $path, removed from lookup',
            );
          } else {
            final parentPath = Directory(path).parent.path;
            final parentFolder = _lookupTable[parentPath];
            if (parentFolder != null) {
              parentFolder.images.removeWhere((img) => img.path == path);
              appLogger.logPageBloc(
                'File deleted: $path, removed from parent folder in lookup',
              );
            } else {
              appLogger.logPageBloc(
                'Failed to delete item',
                error: 'Path not found in lookup: $path',
              );
            }
          }
          yield null;
          continue;
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
          } else {
            appLogger.logPageBloc(
              'Failed to insert folder',
              error: 'Path: $path',
            );
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
          path: path,
          encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
          date: date,
          isPrivateFolder: rootFolder.isPrivateFolder,
        );

        // On macOS, FSEvents fires spurious CREATE events for already-existing
        // files when the watcher first starts (initial state replay). Only
        // notify listeners when the image is genuinely new to avoid triggering
        // a UI refresh for these no-op resync events.
        final wasPresent = parentFolder.images.any((img) => img.path == path);
        parentFolder.images.removeWhere((img) => img.path == path);
        parentFolder.images.add(newImage);
        if (!wasPresent) {
          yield null;
        }
      }
    } finally {
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

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<EncryptedFolder> _loadSubfolder(
    String path,
    bool isPrivateFolder,
  ) async {
    final folder = EncryptedFolder.empty(path, isPrivateFolder);
    final files = Directory(path).listSync();
    for (final fileSystem in files) {
      final fileName = fileSystem.path.split('/').last;
      if (fileName.contains('.')) {
        final date = fileSystem.statSync().modified;
        final bytes = await File(fileSystem.path).readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        folder.images.add(
          EncryptedImage(
            path: fileSystem.path,
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: date,
            isPrivateFolder: isPrivateFolder,
          ),
        );
      } else {
        final subfolder = await _loadSubfolder(
          fileSystem.path,
          isPrivateFolder,
        );
        folder.subfolders.add(subfolder);
      }
    }
    return folder;
  }

  Future<EncryptedFolder> _scanFullFolderPrivate(String path) async {
    final rootFolder = EncryptedFolder.empty(path, true);

    final files = Directory(rootFolder.path).listSync();
    for (final fileSystem in files) {
      final fileName = fileSystem.path.split('/').last;
      if (fileName.contains('.')) {
        final date = fileSystem.statSync().modified;
        final bytes = await File(fileSystem.path).readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        rootFolder.images.add(
          EncryptedImage(
            path: fileSystem.path,
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: date,
            isPrivateFolder: true,
          ),
        );
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path, true);
        rootFolder.subfolders.add(subfolder);
      }
    }

    return rootFolder;
  }

  Future<EncryptedFolder> _scanFullFolderPublic(
    List<AssetEntity> assets,
  ) async {
    final firstFile = await assets.first.file;
    final absoluteFolderPath =
        firstFile?.parent.path ??
        assets.first.relativePath ??
        'Pictures/TornadoGallery';
    final rootFolder = EncryptedFolder.empty(absoluteFolderPath, false);

    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        final bytes = await file.readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        rootFolder.images.add(
          EncryptedImage(
            path: file.path,
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: asset.createDateTime,
            isPrivateFolder: false,
          ),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error loading public image ${asset.id}',
          error: e.toString(),
        );
      }
    }

    return rootFolder;
  }

  bool _removeEncryptedFolder(EncryptedFolder root, EncryptedFolder toRemove) {
    final folder = root.subfolders.firstWhereOrNull(
      (folder) => folder.path == toRemove.path,
    );
    if (folder != null) {
      root.subfolders.remove(folder);
      return true;
    }

    for (final sub in root.subfolders) {
      if (_removeEncryptedFolder(sub, toRemove)) {
        return true;
      }
    }

    return false;
  }

  Map<String, EncryptedFolder> _buildFolderIndex(EncryptedFolder root) {
    final map = <String, EncryptedFolder>{};

    void visit(EncryptedFolder folder) {
      map[folder.path] = folder;
      for (final child in folder.subfolders) {
        visit(child);
      }
    }

    visit(root);
    return map;
  }

  bool insertFolderFast({
    required EncryptedFolder rootFolder,
    required EncryptedFolder newFolder,
  }) {
    final parentPath = Directory(newFolder.path).parent.path;

    EncryptedFolder? findParent(EncryptedFolder folder) {
      if (folder.path == parentPath) return folder;
      for (final sub in folder.subfolders) {
        final found = findParent(sub);
        if (found != null) return found;
      }
      return null;
    }

    final parent = findParent(rootFolder);
    if (parent == null) return false;

    final alreadyExists = parent.subfolders.any(
      (f) => f.path == newFolder.path,
    );
    if (alreadyExists) return false;

    parent.subfolders.add(newFolder);
    return true;
  }

  Future<bool> _recoverMissingParentFolder({
    required EncryptedFolder rootFolder,
    required String parentPath,
    required String rootPath,
  }) async {
    // Watchers can emit file ADD before folder ADD. Rebuild and insert the
    // missing parent so the file event can be processed in the same tick.
    if (!parentPath.startsWith(rootPath)) return false;

    final dir = Directory(parentPath);
    if (!await dir.exists()) return false;

    final recoveredFolder = await _scanFullFolderPrivate(parentPath);
    final inserted = insertFolderFast(
      rootFolder: rootFolder,
      newFolder: recoveredFolder,
    );

    if (!inserted) {
      return _lookupTable.containsKey(parentPath);
    }

    _lookupTable.addAll(_buildFolderIndex(recoveredFolder));
    appLogger.logPageBloc('Recovered missing parent folder in lookup: $parentPath');
    return true;
  }
}
