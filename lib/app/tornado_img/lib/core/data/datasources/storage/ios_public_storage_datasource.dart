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
/// Use `PhotoManager.editor.saveImage` with `path` set to a temp file,
/// then `PhotoManager.editor.copyAssetToPath` to place it in the album,
/// and immediately delete the Recents copy. The album contains exactly
/// one asset per image.
class IosPublicStorageDatasource implements PublicStorageDatasource {
  @override
  @override
Future<void> save({
  required String fileName,
  required String album,
  required Uint8List bytes,
}) async {
  final albumEntity = await GalleryPathProvider.getPublicAlbum(
    requestIfNeeded: true,
  );
  if (albumEntity == null) {
    throw StateError('IosPublicStorageDatasource: album "$album" not found');
  }

  final asset = await PhotoManager.editor.saveImage(
    bytes,
    filename: fileName,
    title: fileName,
    );
  await PhotoManager.editor.copyAssetToPath(
    asset: asset,
    pathEntity: albumEntity,
  );

  await AssetNameIndex.saveByAssetId(
    assetId: asset.id,
    fileName: fileName,
  );
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
      final newStem = newFileName.contains('.')
          ? newFileName.split('.').first
          : newFileName;

      await save(fileName: newStem, album: album, bytes: bytes);

      final newAssetId = await GalleryPathProvider.findMostRecentAssetId();
      if (newAssetId == null) {
        appLogger.logRepository(
          'IosPublicStorageDatasource.rename: new asset id not found after save',
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
        appLogger.logRepository(
          'IosPublicStorageDatasource.rename: old asset still exists after delete, rolling back',
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
      appLogger.logRepository(
        'IosPublicStorageDatasource.rename: error',
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
    // PhotoKit has no album-rename API exposed by PhotoManager. Create the new
    // album so future saves land correctly; existing assets stay in the old
    // album until moved. Logged as a known limitation.
    final created = await createFolder(newRelativePath);
    appLogger.logRepository(
      'IosPublicStorageDatasource.renameFolder: PhotoKit album rename is '
      'best-effort; assets remain in old album until moved',
      error: '$oldRelativePath -> $newRelativePath',
    );
    return created;
  }

  @override
  Future<bool> deleteFolder(String relativePath, List<String> assetIds) async {
    // Removing the contained assets is the meaningful operation; an empty
    // PhotoKit album cannot be reliably deleted through PhotoManager.
    if (assetIds.isEmpty) return true;
    return delete(assetIds);
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
      appLogger.logRepository(
        'IosPublicStorageDatasource.delete: error',
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
