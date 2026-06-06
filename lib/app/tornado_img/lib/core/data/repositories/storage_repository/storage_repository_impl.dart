import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/data/datasources/storage/android_public_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/ios_public_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/private_storage_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/storage/public_storage_datasource.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/asset_name_index.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

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
      final assets = await GalleryPathProvider.getPublicAssets();
      final publicRootPath =
          await GalleryPathProvider.getPublicFolderPath() ??
          'Pictures/TornadoGallery';

      await for (final result in Stream.fromIterable(assets)
          .asyncMap((asset) => _mapPublicAsset(asset, publicRootPath))
          .where((r) => r != null)
          .cast<EncryptedStreamImage>()) {
        yield result;
      }
    } catch (e) {
      appLogger.logRepository(
        'StorageRepositoryImpl.readPublicGalleryImages: error',
        error: e.toString(),
      );
      // Permission denied or gallery unavailable — yield nothing.
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
