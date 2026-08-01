import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/data/datasources/storage/public_storage_datasource.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Android implementation of [PublicStorageDatasource].
///
/// Delegates to [Gal] which writes via MediaStore into `Pictures/<album>`.
/// No double-asset problem on Android because MediaStore manages the index.
class AndroidPublicStorageDatasource implements PublicStorageDatasource {
  @override
  Future<void> save({
    required String fileName,
    required String album,
    required Uint8List bytes,
  }) async {
    await Gal.putImageBytes(bytes, name: fileName, album: album);
  }

  @override
  Future<void> saveVideo({
    required String filePath,
    required String album,
  }) async {
    await Gal.putVideo(filePath, album: album);
  }

  @override
  Future<StorageRenameResult> rename({
    required String assetId,
    required String newFileName,
    required String album,
    required Uint8List bytes,
  }) async {
    // Android exposes a real filesystem path — the file rename is handled by
    // PrivateStorageDatasource via the File API. This method is only called
    // for iOS PhotoKit assets (assetId != null on iOS only).
    // If this is ever reached on Android, log and return failure.
    appLogger.log(
      'AndroidPublicStorageDatasource.rename: unexpected call on Android',
      LogLayer.repository,
      error: 'assetId: $assetId',
    );
    return const StorageRenameResult(success: false);
  }

  @override
  Future<bool> createFolder(String relativePath) async {
    try {
      final path = await GalleryPathProvider.getPublicFolderPath(
        relative: relativePath,
      );
      if (path == null) return false;
      final dir = Directory(path);
      if (await dir.exists()) return false;
      await dir.create(recursive: true);
      return true;
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource.createFolder: error',
        LogLayer.repository,
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Future<bool> renameFolder(
    String oldRelativePath,
    String newRelativePath,
  ) async {
    try {
      final oldPath = await GalleryPathProvider.getPublicFolderPath(
        relative: oldRelativePath,
      );
      final newPath = await GalleryPathProvider.getPublicFolderPath(
        relative: newRelativePath,
      );
      if (oldPath == null || newPath == null) return false;
      final dir = Directory(oldPath);
      if (!await dir.exists() || await Directory(newPath).exists()) {
        return false;
      }
      await dir.rename(newPath);
      return true;
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource.renameFolder: error',
        LogLayer.repository,
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Future<bool> deleteFolder(String relativePath, List<String> assetIds) async {
    var ok = false;

    // Resolve every asset under the folder tree up front (bucket-scoped, fast)
    // and merge with the caller-supplied ids. Firing a single delete() before
    // any slow work means the OS consent dialog appears immediately and, once
    // confirmed, MediaStore deletes all assets atomically — so it survives the
    // app being closed right after. The full-gallery sweep this replaced only
    // surfaced the dialog seconds later, after which a close deleted nothing.
    final all = <String>{...assetIds};
    try {
      all.addAll(await _publicAssetIdsUnderFolder(relativePath));
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource.deleteFolder: asset resolve error',
        LogLayer.repository,
        error: e.toString(),
      );
    }
    if (all.isNotEmpty) ok = await delete(all.toList());

    // dart:io cannot delete MediaStore-managed image files on scoped storage,
    // but after the delete() above the directory holds only empty subfolders,
    // so removing the tree here just cleans up the now-empty directories.
    final path = await GalleryPathProvider.getPublicFolderPath(
      relative: relativePath,
    );
    final dir = path == null ? null : Directory(path);
    try {
      if (dir != null && await dir.exists()) {
        await dir.delete(recursive: true);
        ok = true;
      }
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource.deleteFolder: error',
        LogLayer.repository,
        error: e.toString(),
      );
    }
    return ok;
  }

  /// Returns the MediaStore asset IDs of every image that lives under the
  /// public folder identified by [relativePath] (including nested subfolders).
  ///
  /// Needed because MediaStore groups images by their on-disk bucket, so a
  /// subfolder's assets are not part of the app's named album. Filtering the
  /// "all" album by `relativePath` is the only reliable way to find them.
  Future<List<String>> _publicAssetIdsUnderFolder(String relativePath) async {
    final ids = <String>[];
    try {
      final permission = await PhotoManager.getPermissionState(
        requestOption: PermissionRequestOption(),
      );
      if (permission == PermissionState.denied ||
          permission == PermissionState.restricted) {
        return ids;
      }

      final rel = relativePath
          .replaceAll('\\', '/')
          .split('/')
          .where((p) => p.trim().isNotEmpty)
          .join('/');
      if (rel.isEmpty) return ids;

      final target = 'Pictures/${Constants.appFolderName}/$rel'.toLowerCase();

      // Each album is one MediaStore bucket (= one on-disk directory). Sample
      // a single asset per album to read its relativePath, then fully page only
      // the buckets under the target folder tree. This keeps the cost at
      // O(buckets + assets_in_folder) instead of scanning the whole gallery.
      String bucketRel(AssetEntity a) {
        var r = (a.relativePath ?? '').replaceAll('\\', '/').toLowerCase();
        if (r.endsWith('/')) r = r.substring(0, r.length - 1);
        return r;
      }

      // `common`, not `image`: an image-only query would leave the folder's
      // encrypted videos behind on delete.
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );

      const pageSize = 500;
      for (final album in albums) {
        final sample = await album.getAssetListPaged(page: 0, size: 1);
        if (sample.isEmpty) continue;
        final rel = bucketRel(sample.first);
        if (rel != target && !rel.startsWith('$target/')) continue;

        var page = 0;
        while (true) {
          final assets = await album.getAssetListPaged(
            page: page,
            size: pageSize,
          );
          if (assets.isEmpty) break;
          for (final a in assets) {
            ids.add(a.id);
          }
          if (assets.length < pageSize) break;
          page++;
        }
      }
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource._publicAssetIdsUnderFolder: error',
        LogLayer.repository,
        error: e.toString(),
      );
    }
    return ids;
  }

  @override
  Stream<String> listFolderPaths() async* {
    final root = await GalleryPathProvider.getPublicFolderPath();
    if (root == null) return;
    final dir = Directory(root);
    if (!await dir.exists()) return;

    final rootPath = root.replaceAll('\\', '/');
    try {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! Directory) continue;
        final p = entity.path.replaceAll('\\', '/');
        if (p.startsWith('$rootPath/')) yield p.substring(rootPath.length + 1);
      }
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource.listFolderPaths: error',
        LogLayer.repository,
        error: e.toString(),
      );
    }
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
        // MediaStore delete can complete asynchronously — confirm by checking existence.
        final stillExists = await AssetEntity.fromId(id) != null;
        if (!stillExists) success = true;
      }

      return success;
    } catch (e) {
      appLogger.log(
        'AndroidPublicStorageDatasource: error deleting assets',
        LogLayer.repository,
        error: e.toString(),
      );
      return false;
    }
  }
}
