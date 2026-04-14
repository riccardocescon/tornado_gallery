import 'dart:async';
import 'dart:io';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
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
    if (assets.isEmpty) return null;

    final rootFolder = await _scanFullFolderPublic(assets);
    _lookupTable.addAll(_buildFolderIndex(rootFolder));
    return rootFolder;
  }

  @override
  Stream<void> watchFolderChanges(EncryptedFolder rootFolder) async* {
    final encryptedDir = Directory(rootFolder.path);
    final folderStream = encryptedDir.watch(
      events: FileSystemEvent.create | FileSystemEvent.delete,
      recursive: true,
    );

    await _streamManagers[rootFolder.path]?.dispose();
    final sm = StreamManager.fromStream(folderStream);
    _streamManagers[rootFolder.path] = sm;

    try {
      await for (final event in sm.stream) {
        appLogger.logPageBloc(
          "Received file system event: ${event.toString()}",
        );
        final isDirectory =
            event.isDirectory || !event.path.split('/').last.contains('.');
        if (isDirectory) {
          if (event.type == FileSystemEvent.delete) {
            final folder = _lookupTable[event.path];
            if (folder != null) {
              _removeEncryptedFolder(rootFolder, folder);
              _lookupTable.remove(event.path);
            }
            appLogger.logPageBloc(
              'Folder deleted: ${event.path}, removed from lookup',
            );
            yield null;
            continue;
          }

          final newFolder = await _scanFullFolderPrivate(event.path);

          final inserted = insertFolderFast(
            rootFolder: rootFolder,
            newFolder: newFolder,
          );

          if (inserted) {
            yield null;
          } else {
            appLogger.logPageBloc(
              'Failed to insert folder',
              error: 'Path: ${event.path}',
            );
          }
          continue;
        }

        if (event.type == FileSystemEvent.delete) {
          final parentPath = Directory(event.path).parent.path;
          final parentFolder = _lookupTable[parentPath];
          if (parentFolder != null) {
            parentFolder.images.removeWhere((img) => img.path == event.path);
            appLogger.logPageBloc(
              'File deleted: ${event.path}, removed from parent folder in lookup',
            );
          } else {
            appLogger.logPageBloc(
              'Failed to delete file',
              error:
                  'Parent folder not found in lookup for path: ${event.path}',
            );
          }
          yield null;
          continue;
        }

        final parentPath = Directory(event.path).parent.path;
        final parentFolder = _lookupTable[parentPath];
        if (parentFolder == null) {
          appLogger.logPageBloc(
            'Failed to add new file',
            error: 'Parent folder not found in lookup for path: ${event.path}',
          );
          continue;
        }

        final file = File(event.path);
        final date = file.statSync().modified;
        final bytes = await file.readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        final newImage = EncryptedImage(
          path: event.path,
          encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
          date: date,
        );

        parentFolder.images.removeWhere((img) => img.path == event.path);
        parentFolder.images.add(newImage);
        yield null;
      }
    } finally {
      await _streamManagers[rootFolder.path]?.dispose();
      _streamManagers.remove(rootFolder.path);
    }
  }

  @override
  Future<bool> createPublicFolder() async {
    try {
      final publicAsset = await GalleryPathProvider.getPublicFolder();
      if (publicAsset != null) return true;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/noimg.jpg');
      await tempFile.writeAsBytes([]);

      await Gal.putImage(tempFile.path, album: Constants.appFolderName);

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

        images.add(
          GalleryImage(id: asset.id, file: file, date: asset.createDateTime),
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

  Future<EncryptedFolder> _loadSubfolder(String path) async {
    final folder = EncryptedFolder.empty(path);
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
          ),
        );
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path);
        folder.subfolders.add(subfolder);
      }
    }
    return folder;
  }

  Future<EncryptedFolder> _scanFullFolderPrivate(String path) async {
    final rootFolder = EncryptedFolder.empty(path);

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
          ),
        );
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path);
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
    final rootFolder = EncryptedFolder.empty(absoluteFolderPath);

    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file == null) continue;
        if (file.path.endsWith(Constants.noImageName)) continue;

        final bytes = await file.readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        rootFolder.images.add(
          EncryptedImage(
            path: file.path,
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: asset.createDateTime,
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
}
