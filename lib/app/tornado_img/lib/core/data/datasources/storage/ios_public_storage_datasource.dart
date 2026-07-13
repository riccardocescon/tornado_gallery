import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/data/datasources/storage/public_storage_datasource.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/asset_name_index.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// iOS implementation of [PublicStorageDatasource].
///
/// Uses [PhotoManager] directly instead of [Gal] to avoid the double-asset bug.
///
/// ## Why Gal causes duplicates on iOS
/// `Gal.putImageBytes(album: ...)` internally:
///   1. Saves the asset to the "Recents" album (creates asset A).
///   2. Copies asset A into the target album (creates asset B).
/// Both A and B are distinct PhotoKit assets. When [GalleryPathProvider]
/// reads the TornadoGallery album it finds both, so every saved image
/// appears twice in the UI.
///
/// ## Fix
/// Use `PhotoManager.editor.saveImage` to save to Recents, then
/// `PhotoManager.editor.copyAssetToPath` to add it to the target album.
/// The Recents copy is intentionally left in place — `deleteWithIds` always
/// surfaces an iOS confirmation dialog, and the app only reads TornadoGallery
/// albums so the Recents copy is never shown in the UI.
class IosPublicStorageDatasource implements PublicStorageDatasource {
  @override
  @override
  Future<void> save({
    required String fileName,
    required String album,
    required Uint8List bytes,
  }) async {
    final albumEntity = await GalleryPathProvider.getOrCreatePublicAlbum(album);
    if (albumEntity == null) {
      throw StateError('IosPublicStorageDatasource: album "$album" not found');
    }

    final recentsAsset = await PhotoManager.editor.saveImage(
      bytes,
      filename: fileName,
      title: fileName,
    );
    final albumAsset = await PhotoManager.editor.copyAssetToPath(
      asset: recentsAsset,
      pathEntity: albumEntity,
    );

    // ponytail: skip Recents cleanup — deleteWithIds always shows an iOS
    // confirmation dialog; the app reads only TornadoGallery albums so the
    // Recents copy is invisible to the app UI.

    final resolvedId = albumAsset.id;
    await AssetNameIndex.saveByAssetId(assetId: resolvedId, fileName: fileName);
    await AssetNameIndex.saveByHash(
      hash: ByteModeling.generateHash(bytes),
      fileName: fileName,
    );
  }

  @override
  Future<StorageRenameResult> rename({
    required String assetId,
    required String newFileName,
    required String album,
    required Uint8List bytes,
  }) async {
    try {
      // PhotoKit has no rename API — save new asset, delete old one atomically.
      final newStem =
          newFileName.contains('.')
              ? newFileName.split('.').first
              : newFileName;

      await save(fileName: newStem, album: album, bytes: bytes);

      final newAssetId = await GalleryPathProvider.findMostRecentAssetId(
        albumName: album,
      );
      if (newAssetId == null) {
        appLogger.log(
          'IosPublicStorageDatasource.rename: new asset id not found after save',
          LogLayer.repository,
        );
        return const StorageRenameResult(success: false);
      }

      // Delete old asset.
      await PhotoManager.editor.deleteWithIds([assetId]);

      var oldStillExists = await _assetExistsById(assetId);
      if (oldStillExists) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        oldStillExists = await _assetExistsById(assetId);
      }

      if (oldStillExists) {
        // Rollback: remove the newly saved asset to keep state consistent.
        await PhotoManager.editor.deleteWithIds([newAssetId]);
        appLogger.log(
          'IosPublicStorageDatasource.rename: old asset still exists after delete, rolling back',
          LogLayer.repository,
          error: 'oldAssetId: $assetId',
        );
        return const StorageRenameResult(success: false);
      }

      await AssetNameIndex.saveByAssetId(
        assetId: newAssetId,
        fileName: newFileName,
      );
      return StorageRenameResult(success: true, newAssetId: newAssetId);
    } catch (e) {
      appLogger.log(
        'IosPublicStorageDatasource.rename: error',
        LogLayer.repository,
        error: e.toString(),
      );
      return const StorageRenameResult(success: false);
    }
  }

  @override
  Future<bool> createFolder(String relativePath) async {
    final albumName = GalleryPathProvider.getPublicAlbumName(relativePath);
    final album = await GalleryPathProvider.getOrCreatePublicAlbum(albumName);
    return album != null;
  }

  @override
  Future<bool> renameFolder(
    String oldRelativePath,
    String newRelativePath,
  ) async {
    final oldAlbumName = GalleryPathProvider.getPublicAlbumName(
      oldRelativePath,
    );
    final newAlbumName = GalleryPathProvider.getPublicAlbumName(
      newRelativePath,
    );

    final oldAlbums = await GalleryPathProvider.listPublicAlbumsUnder(
      oldAlbumName,
    );
    if (oldAlbums.isEmpty) {
      // No album existed yet — just create the new one.
      return (await GalleryPathProvider.getOrCreatePublicAlbum(newAlbumName)) !=
          null;
    }

    for (final oldAlbum in oldAlbums) {
      // Map "TornadoGallery/old[/sub]" → "TornadoGallery/new[/sub]".
      final correspondingNewName =
          newAlbumName + oldAlbum.name.substring(oldAlbumName.length);
      final newAlbum = await GalleryPathProvider.getOrCreatePublicAlbum(
        correspondingNewName,
      );
      if (newAlbum == null) {
        appLogger.log(
          'IosPublicStorageDatasource.renameFolder: could not create album',
          LogLayer.repository,
          error: correspondingNewName,
        );
        continue;
      }

      // copyAssetToPath adds the existing asset to the new album (same ID —
      // no copy is made in the library), so AssetNameIndex stays valid.
      final assets = await oldAlbum.getAssetListPaged(page: 0, size: 10000);
      for (final asset in assets) {
        try {
          await PhotoManager.editor.copyAssetToPath(
            asset: asset,
            pathEntity: newAlbum,
          );
        } catch (e) {
          appLogger.log(
            'IosPublicStorageDatasource.renameFolder: could not move asset',
            LogLayer.repository,
            error: '${asset.id}: $e',
          );
        }
      }

      // Remove from old album without deleting from library (no dialog).
      if (assets.isNotEmpty) {
        await PhotoManager.editor.darwin.removeAssetsInAlbum(assets, oldAlbum);
      }

      try {
        await PhotoManager.editor.darwin.deletePath(oldAlbum);
      } catch (e) {
        appLogger.log(
          'IosPublicStorageDatasource.renameFolder: could not delete old album',
          LogLayer.repository,
          error: '${oldAlbum.name}: $e',
        );
      }
    }

    return true;
  }

  @override
  Future<bool> deleteFolder(String relativePath, List<String> assetIds) async {
    final albumPrefix = GalleryPathProvider.getPublicAlbumName(relativePath);
    final albums = await GalleryPathProvider.listPublicAlbumsUnder(albumPrefix);

    // Delete album structure first — iOS shows the album-permission dialog here.
    // Aborting before touching assets lets the user cancel without losing photos.
    for (final album in albums) {
      try {
        final deleted = await PhotoManager.editor.darwin.deletePath(album);
        if (!deleted) return false;
      } catch (e) {
        appLogger.log(
          'IosPublicStorageDatasource.deleteFolder: album delete failed',
          LogLayer.repository,
          error: '${album.name}: $e',
        );
        return false;
      }
    }

    // Album confirmed — now delete the assets (shows the photos-permission dialog).
    return assetIds.isEmpty || await delete(assetIds);
  }

  @override
  Future<bool> delete(List<String> assetIds) async {
    if (assetIds.isEmpty) return false;

    try {
      final deleted = await PhotoManager.editor.deleteWithIds(assetIds);
      final deletedSet = deleted.toSet();
      var success = false;

      for (final id in assetIds) {
        if (deletedSet.contains(id)) {
          success = true;
          continue;
        }
        // PhotoKit delete can complete asynchronously — confirm by checking existence.
        final stillExists = await _assetExistsById(id);
        if (!stillExists) success = true;
      }

      return success;
    } catch (e) {
      appLogger.log(
        'IosPublicStorageDatasource.delete: error',
        LogLayer.repository,
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Stream<String> listFolderPaths() async* {
    final rootAlbum = GalleryPathProvider.getPublicAlbumName('');
    final albums = await GalleryPathProvider.listPublicAlbumsUnder(rootAlbum);
    for (final album in albums) {
      if (album.name == rootAlbum) continue;
      final rel = album.name.substring(rootAlbum.length + 1);
      if (rel.trim().isNotEmpty) yield rel;
    }
  }

  Future<bool> _assetExistsById(String assetId) async {
    final entity = await AssetEntity.fromId(assetId);
    return entity != null;
  }
}
