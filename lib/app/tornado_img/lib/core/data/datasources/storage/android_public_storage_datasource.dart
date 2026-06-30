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
    appLogger.logRepository(
      'AndroidPublicStorageDatasource.rename: unexpected call on Android',
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
      appLogger.logRepository(
        'AndroidPublicStorageDatasource.createFolder: error',
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
      appLogger.logRepository(
        'AndroidPublicStorageDatasource.renameFolder: error',
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Future<bool> deleteFolder(String relativePath, List<String> assetIds) async {
    var ok = false;
    if (assetIds.isNotEmpty) ok = await delete(assetIds);

    // dart:io cannot delete MediaStore-managed image files on scoped storage,
    // which leaves the directory non-empty (errno 39) when [assetIds] does not
    // cover every asset under the folder (e.g. subfolders or untracked images).
    // Sweep MediaStore for all assets living under this folder tree and delete
    // them via PhotoManager before removing the directory itself.
    try {
      final passed = assetIds.toSet();
      final remaining =
          (await _publicAssetIdsUnderFolder(relativePath))
              .where((id) => !passed.contains(id))
              .toList();
      if (remaining.isNotEmpty && await delete(remaining)) ok = true;
    } catch (e) {
      appLogger.logRepository(
        'AndroidPublicStorageDatasource.deleteFolder: asset sweep error',
        error: e.toString(),
      );
    }

    try {
      final path = await GalleryPathProvider.getPublicFolderPath(
        relative: relativePath,
      );
      if (path != null) {
        final dir = Directory(path);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          ok = true;
        }
      }
    } catch (e) {
      appLogger.logRepository(
        'AndroidPublicStorageDatasource.deleteFolder: error',
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

      final target =
          'Pictures/${Constants.appFolderName}/$rel'.toLowerCase();

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      AssetPathEntity? all;
      for (final a in albums) {
        if (a.isAll) {
          all = a;
          break;
        }
      }
      if (all == null) return ids;

      const pageSize = 500;
      var page = 0;
      while (true) {
        final assets = await all.getAssetListPaged(page: page, size: pageSize);
        if (assets.isEmpty) break;
        for (final a in assets) {
          var assetRel = (a.relativePath ?? '')
              .replaceAll('\\', '/')
              .toLowerCase();
          if (assetRel.endsWith('/')) {
            assetRel = assetRel.substring(0, assetRel.length - 1);
          }
          if (assetRel == target || assetRel.startsWith('$target/')) {
            ids.add(a.id);
          }
        }
        if (assets.length < pageSize) break;
        page++;
      }
    } catch (e) {
      appLogger.logRepository(
        'AndroidPublicStorageDatasource._publicAssetIdsUnderFolder: error',
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
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! Directory) continue;
        final p = entity.path.replaceAll('\\', '/');
        if (p.startsWith('$rootPath/')) yield p.substring(rootPath.length + 1);
      }
    } catch (e) {
      appLogger.logRepository(
        'AndroidPublicStorageDatasource.listFolderPaths: error',
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
      appLogger.logRepository(
        'AndroidPublicStorageDatasource: error deleting assets',
        error: e.toString(),
      );
      return false;
    }
  }
}
