import 'dart:async';
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/public_folder_datasource.dart';
import 'package:tornado_img_app/core/data/mappers/asset_mapper.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:watcher/watcher.dart';

/// Android implementation of [PublicFolderDatasource].
///
/// Uses the real `Pictures/<AppName>` path and a [DirectoryWatcher] for
/// real-time change detection — same mechanism as the private folder.
class AndroidPublicFolderDatasource implements PublicFolderDatasource {
  @override
  Future<bool> createFolder() async {
    try {
      final path = await GalleryPathProvider.getPublicFolderPath();
      if (path == null) return false;
      await Directory(path).create(recursive: true);
      return true;
    } catch (e) {
      appLogger.log(
        'AndroidPublicFolderDatasource: error creating folder',
        LogLayer.usecase,
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Future<List<AssetEntity>> getAssets() =>
      GalleryPathProvider.getPublicAssets(requestIfNeeded: true);

  @override
  Future<EncryptedFolder?> loadRoot() async {
    final assets = await getAssets();
    final path = await GalleryPathProvider.getPublicFolderPath();

    if (path == null) return null;

    if (assets.isEmpty) {
      // Folder may have just been created — return empty root so the
      // watcher can attach and detect the first image being added.
      if (!await Directory(path).exists()) return null;
      // The root bucket may hold no loose images while subfolders do; walk
      // them so they show up on first load even without top-level images.
      final folder = EncryptedFolder.empty(path, false);
      await _attachSubfolders(folder);
      return folder;
    }

    return _buildFolder(assets, path);
  }

  @override
  Stream<void> watchFolder(EncryptedFolder rootFolder) async* {
    final path = rootFolder.path;
    if (path.trim().isEmpty) return;

    final dir = Directory(path);
    if (!await dir.exists()) return;

    final watcher = DirectoryWatcher(dir.path);
    await watcher.ready;

    await for (final event in watcher.events) {
      if (event.type == ChangeType.ADD || event.type == ChangeType.REMOVE) {
        yield null;
      }
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<EncryptedFolder> _buildFolder(
    List<AssetEntity> assets,
    String folderPath,
  ) async {
    final folder = EncryptedFolder.empty(folderPath, false);

    for (final asset in assets) {
      try {
        final image = await AssetMapper.fromAsset(
          asset: asset,
          folderPath: folderPath,
        );
        if (image != null) folder.images.add(image);
      } catch (e) {
        appLogger.log(
          'AndroidPublicFolderDatasource: error mapping asset ${asset.id}',
          LogLayer.pageBloc,
          error: e.toString(),
        );
      }
    }

    // Android gallery folders are real subdirectories of Pictures/<AppName>.
    // The PhotoKit asset list only covers the root bucket, so subfolders are
    // discovered by walking the filesystem; their images' asset IDs are
    // resolved best-effort by filename for later deletion.
    await _attachSubfolders(folder);

    return folder;
  }

  Future<void> _attachSubfolders(EncryptedFolder folder) async {
    final dir = Directory(folder.path);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final subfolder = await _scanDir(entity);
      folder.subfolders.add(subfolder);
    }
  }

  Future<EncryptedFolder> _scanDir(Directory dir) async {
    final folder = EncryptedFolder.empty(dir.path, false);

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is Directory) {
        folder.subfolders.add(await _scanDir(entity));
        continue;
      }
      if (entity is! File) continue;

      final image = await _fileToPublicImage(File(entity.path));
      if (image != null) folder.images.add(image);
    }

    return folder;
  }

  Future<EncryptedImage?> _fileToPublicImage(File file) async {
    final ext = FileNameUtils.extensionOf(file.path);
    if (!Constants.imageExtensions.contains(ext)) return null;

    try {
      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);
      final fileName = FileNameUtils.basename(file.path);
      final assetId = await GalleryPathProvider.findAssetIdByName(fileName);

      return EncryptedImage(
        storagePath: StoragePath(
          path: file.path,
          isPrivateFolder: false,
          assetId: assetId,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: await file.lastModified(),
      );
    } catch (e) {
      appLogger.log(
        'AndroidPublicFolderDatasource: error reading subfolder file ${file.path}',
        LogLayer.pageBloc,
        error: e.toString(),
      );
      return null;
    }
  }
}
