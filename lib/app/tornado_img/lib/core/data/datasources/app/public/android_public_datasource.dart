import 'dart:async';
import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/public_folder_datasource.dart';
import 'package:tornado_img_app/core/data/mappers/asset_mapper.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
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
      appLogger.logUsecase(
        'AndroidPublicFolderDatasource: error creating folder',
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
      return EncryptedFolder.empty(path, false);
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
        appLogger.logPageBloc(
          'AndroidPublicFolderDatasource: error mapping asset ${asset.id}',
          error: e.toString(),
        );
      }
    }

    return folder;
  }
}
