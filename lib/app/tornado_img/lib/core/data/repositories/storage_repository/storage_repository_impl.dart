import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/data/datasources/storage/android_public_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/ios_public_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/private_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/public_storage_datasource.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/asset_name_index.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';

/// Orchestrates all storage operations across private filesystem and
/// public gallery, delegating platform-specific work to the datasources.
///
/// Has no knowledge of [Gal], [PhotoManager], or [File] directly.
class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl()
      : _publicDatasource = Platform.isIOS
            ? IosPublicStorageDatasource()
            : AndroidPublicStorageDatasource();

  final PrivateStorageDatasource _private = PrivateStorageDatasource();
  final PublicStorageDatasource _publicDatasource;

  // ── Save ────────────────────────────────────────────────────────────────────

  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String? path,
    required String? album,
  }) async {
    try {
      if (path == null) {
        // Public gallery save.
        await _publicDatasource.save(
          fileName: fileName,
          album: album ?? '',
          bytes: bytes,
        );
        return;
      }

      // Private filesystem save.
      await _private.save(path: path, fileName: fileName, bytes: bytes);
    } catch (e) {
      appLogger.logRepository('StorageRepositoryImpl.save: error', error: e.toString());
      rethrow;
    }
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  @override
  Stream<EncryptedStreamImage> readPrivateImages(String path) async* {
    final dir = Directory(path);
    appLogger.logRepository('StorageRepositoryImpl: reading private images from $path');

    if (!await dir.exists()) {
      appLogger.logRepository('StorageRepositoryImpl: directory not found: $path');
      return;
    }

    yield* _private.readAllImages(dir).asyncMap(
      (image) => EncryptedStreamImage.image(
        image: image,
        type: EncryptedStreamImageType.newImage,
      ),
    );
  }

  @override
  Stream<EncryptedStreamImage> readPublicGalleryImages() async* {
    try {
      if (Platform.isAndroid) {
        // Android gallery folders are real subdirectories of the root album.
        // PhotoKit's asset list only covers the root bucket, so walk the
        // filesystem to also pick up images nested in subfolders and keep
        // their real (nested) path — driving the archive folder tree.
        yield* _readPublicImagesAndroid();
        return;
      }

      // Read per-album so each asset gets the correct virtual path matching
      // the TornadoGallery/<subfolder> convention used by _attachSubfolders.
      // Deeper albums first so each asset is assigned its most-specific path.
      final allAlbums = await GalleryPathProvider.listPublicAlbumsUnder(
        Constants.appFolderName,
      );
      allAlbums.sort((a, b) => b.name.length.compareTo(a.name.length));
      final seen = <String>{};
      for (final album in allAlbums) {
        try {
          final albumAssets =
              await album.getAssetListPaged(page: 0, size: 10000);
          for (final asset in albumAssets) {
            if (!seen.add(asset.id)) continue;
            final result = await _mapPublicAsset(asset, album.name);
            if (result != null) yield result;
          }
        } catch (e) {
          appLogger.logRepository(
            'StorageRepositoryImpl.readPublicGalleryImages: ${album.name} error',
            error: e.toString(),
          );
        }
      }
    } catch (e) {
      appLogger.logRepository(
        'StorageRepositoryImpl.readPublicGalleryImages: error',
        error: e.toString(),
      );
      // Permission denied or gallery unavailable — yield nothing.
    }
  }

  Stream<EncryptedStreamImage> _readPublicImagesAndroid() async* {
    final root = await GalleryPathProvider.getPublicFolderPath();
    if (root == null) return;
    final dir = Directory(root);
    if (!await dir.exists()) return;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final image = await _fileToPublicImage(File(entity.path));
      if (image == null) continue;
      yield EncryptedStreamImage.image(
        image: image,
        type: EncryptedStreamImageType.newImage,
      );
    }
  }

  Future<EncryptedImage?> _fileToPublicImage(File file) async {
    final ext = FileNameUtils.extensionOf(file.path);
    if (!Constants.imageExtensions.contains(ext)) return null;

    try {
      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);
      final fileName = FileNameUtils.basename(file.path);
      // Best-effort asset ID for later deletion via MediaStore.
      final assetId = await GalleryPathProvider.findAssetIdByName(fileName);

      return EncryptedImage(
        // Keep the real, nested filesystem path so [storeRelativeDir] resolves
        // the subfolder the image lives in.
        storagePath: StoragePath(
          path: file.path,
          isPrivateFolder: false,
          assetId: assetId,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: await file.lastModified(),
      );
    } catch (e) {
      appLogger.logRepository(
        'StorageRepositoryImpl: error reading public file ${file.path}',
        error: e.toString(),
      );
      return null;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────

  @override
  Future<bool> delete(List<StoragePath> images) async {
    final publicIds = images
        .where((img) => img.assetId != null)
        .map((img) => img.assetId!)
        .toList();

    final privatePaths = images
        .where((img) => img.assetId == null)
        .map((img) => img.path)
        .toList();

    final publicDeleted =
        publicIds.isNotEmpty ? await _publicDatasource.delete(publicIds) : false;

    final privateDeleted =
        privatePaths.isNotEmpty ? await _private.delete(privatePaths) : false;

    return publicDeleted || privateDeleted;
  }

  // ── Rename ──────────────────────────────────────────────────────────────────

  @override
  Future<StorageRenameResult> rename(
    String path,
    String oldFileName,
    String newFileName, {
    String? assetId,
    Uint8List? bytes,
    String? album,
  }) async {
    // iOS public gallery asset rename.
    if (assetId != null && Platform.isIOS) {
      if (bytes == null) {
        appLogger.logRepository(
          'StorageRepositoryImpl.rename: missing bytes for gallery asset rename',
          error: 'assetId: $assetId',
        );
        return const StorageRenameResult(success: false);
      }

      return _publicDatasource.rename(
        assetId: assetId,
        newFileName: newFileName,
        album: album ?? '',
        bytes: bytes,
      );
    }

    // Private filesystem rename.
    return _private.rename(
      path: path,
      oldFileName: oldFileName,
      newFileName: newFileName,
    );
  }

  // ── Folder operations ─────────────────────────────────────────────────────────

  @override
  Future<bool> createFolder({
    required bool isPrivate,
    required String relativePath,
  }) async {
    if (isPrivate) {
      final base = await GalleryPathProvider.getPrivateFolderPath();
      return _private.createFolder('$base/$relativePath');
    }
    return _publicDatasource.createFolder(relativePath);
  }

  @override
  Future<bool> renameFolder({
    required bool isPrivate,
    required String oldRelativePath,
    required String newRelativePath,
  }) async {
    if (isPrivate) {
      final base = await GalleryPathProvider.getPrivateFolderPath();
      return _private.renameFolder(
        '$base/$oldRelativePath',
        '$base/$newRelativePath',
      );
    }
    return _publicDatasource.renameFolder(oldRelativePath, newRelativePath);
  }

  @override
  Future<bool> deleteFolder({
    required bool isPrivate,
    required String relativePath,
    required List<StoragePath> contained,
  }) async {
    if (isPrivate) {
      final base = await GalleryPathProvider.getPrivateFolderPath();
      return _private.deleteFolder('$base/$relativePath');
    }
    final assetIds =
        contained.map((p) => p.assetId).whereType<String>().toList();
    return _publicDatasource.deleteFolder(relativePath, assetIds);
  }

  @override
  Stream<String> readPrivateFolderPaths(String rootPath) {
    final dir = Directory(rootPath);
    if (!dir.existsSync()) return const Stream<String>.empty();
    return _private.listSubdirectories(dir);
  }

  @override
  Stream<String> readPublicFolderPaths() => _publicDatasource.listFolderPaths();

  @override
  Future<StorageMoveResult> moveImages({
    required List<EncryptedImage> images,
    required String targetRelativePath,
  }) async {
    final movedPrivate = <String, String>{};
    var anySuccess = false;

    for (final image in images) {
      final storage = image.storagePath;
      final fileName = image.name;

      if (storage.isPrivateFolder) {
        final base = await GalleryPathProvider.getPrivateFolderPath();
        final targetDir =
            targetRelativePath.isEmpty ? base : '$base/$targetRelativePath';
        final newPath = '$targetDir/$fileName';
        if (newPath == storage.path) continue;
        final result = await _private.moveFile(storage.path, newPath);
        if (result != null) {
          movedPrivate[storage.path] = result;
          anySuccess = true;
        }
      } else if (Platform.isAndroid) {
        // Android public gallery is a real filesystem path (same as folder
        // ops), so move the file directly. iOS assets have no path and must go
        // through the assetId save+delete flow below.
        final base = await GalleryPathProvider.getPublicFolderPath();
        if (base == null) continue;
        final targetDir =
            targetRelativePath.isEmpty ? base : '$base/$targetRelativePath';
        final newPath = '$targetDir/$fileName';
        if (newPath == storage.path) continue;
        final result = await _private.moveFile(storage.path, newPath);
        if (result != null) {
          movedPrivate[storage.path] = result;
          anySuccess = true;
        }
      } else {
        // iOS: copy bytes into the target album, then delete the original.
        final assetId = storage.assetId;
        if (assetId == null) continue;
        try {
          final albumName =
              GalleryPathProvider.getPublicAlbumName(targetRelativePath);
          await _publicDatasource.save(
            fileName: fileName.split('.').first,
            album: albumName,
            bytes: image.encryptedInfo.bytes,
          );
          await _publicDatasource.delete([assetId]);
          // Map old virtual path → new virtual path so the caller can update
          // the in-memory model without waiting for the next poll cycle.
          movedPrivate[storage.path] = '$albumName/$fileName';
          anySuccess = true;
        } catch (e) {
          appLogger.logRepository(
            'StorageRepositoryImpl.moveImages: gallery move failed',
            error: e.toString(),
          );
        }
      }
    }

    return StorageMoveResult(
      success: anySuccess,
      movedPrivatePaths: movedPrivate,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  @override
  Future<bool> imageExists(String path, String fileName) async {
    final file = File('$path/$fileName');
    return file.exists();
  }

  Future<EncryptedStreamImage?> _mapPublicAsset(
    dynamic asset,
    String publicRootPath,
  ) async {
    try {
      final file = await asset.file;
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);

      final String storagePath;
      if (Platform.isAndroid) {
        storagePath = '$publicRootPath/${file.path.split('/').last}';
      } else if (Platform.isIOS) {
        final mappedByAssetId = await AssetNameIndex.resolveByAssetId(asset.id);
        final mappedByHash = mappedByAssetId ?? await AssetNameIndex.resolveByHash(hash);
        final displayFileName = mappedByHash ??
            await GalleryPathProvider.resolveAssetDisplayName(
              asset,
              fallbackFilePath: file.path,
            );
        storagePath = '$publicRootPath/$displayFileName';
      } else {
        throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
      }

      final encryptedImage = EncryptedImage(
        storagePath: StoragePath(
          path: storagePath,
          isPrivateFolder: false,
          assetId: asset.id,
        ),
        date: asset.createDateTime,
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
      );

      return EncryptedStreamImage.image(
        image: encryptedImage,
        type: EncryptedStreamImageType.newImage,
      );
    } catch (e) {
      appLogger.logRepository(
        'StorageRepositoryImpl: error mapping public asset ${asset.id}',
        error: e.toString(),
      );
      return null;
    }
  }
}
