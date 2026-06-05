import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/asset_name_index.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

part 'storage_repository_utils.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageRepositoryUtils utils = StorageRepositoryUtils();

  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String? path,
    required String? album,
  }) async {
    try {
      if (path == null) {
        await Gal.putImageBytes(
          bytes,
          name: fileName,
          album: album,
        );

        if (Platform.isIOS) {
          final recentAssetId =
              await GalleryPathProvider.findMostRecentAssetId();
          if (recentAssetId != null) {
            await AssetNameIndex.saveByAssetId(
              assetId: recentAssetId,
              fileName: fileName,
            );
          }

          final hash = ByteModeling.generateHash(bytes);
          await AssetNameIndex.saveByHash(
            hash: hash,
            fileName: fileName,
          );
        }
        return;
      }
      
      final file = File('$path/$fileName');

      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    } catch (e) {
      appLogger.logRepository('Error saving image', error: e.toString());
      rethrow;
    }
  }

  @override
  Stream<EncryptedStreamImage> readPrivateImages(String path) async* {
    final dir = Directory(path);
    appLogger.logRepository('Reading images from $path');
    if (!await dir.exists()) {
      appLogger.logRepository('Directory does not exist: $path');
      return;
    }

    yield* utils.readAllImagesRecursively(dir).asyncMap((image) {
      return EncryptedStreamImage.image(
        image: image,
        type: EncryptedStreamImageType.newImage,
      );
    });
  }

  @override
  Stream<EncryptedStreamImage> readPublicGalleryImages() async* {
    try {
      final assets = await GalleryPathProvider.getPublicAssets();
      final publicRootPath =
          await GalleryPathProvider.getPublicFolderPath() ??
          'Pictures/TornadoGallery';

      final fileStream = Stream.fromIterable(
        assets,
      ).asyncMap<EncryptedStreamImage?>((asset) async {
        try {
          final file = await asset.file;
          if (file == null) return null;

          final bytes = await file.readAsBytes();
          final hash = ByteModeling.generateHash(bytes);

          String storagePath;
          if (Platform.isAndroid) {
            storagePath = '$publicRootPath/${file.path.split('/').last}';
          } else if (Platform.isIOS) {
            final mappedByAssetId =
                await AssetNameIndex.resolveByAssetId(
                  asset.id,
                );
            final mappedFileName =
                mappedByAssetId ??
                await AssetNameIndex.resolveByHash(hash);
            final displayFileName =
                mappedFileName ??
                await GalleryPathProvider.resolveAssetDisplayName(
                  asset,
                  fallbackFilePath: file.path,
                );
            storagePath = '$publicRootPath/$displayFileName';
          } else {
            throw UnsupportedError(
              'Unsupported platform: ${Platform.operatingSystem}',
            );
          }

          final encryptedImage = EncryptedImage(
            storagePath: StoragePath(
              path: storagePath,
              isPrivateFolder: false,
              assetId: asset.id,
            ),
            date: asset.createDateTime,
            encryptedInfo: BytesInfo(
              bytes: bytes,
              hash: hash,
            ),
          );

          return EncryptedStreamImage.image(
            image: encryptedImage,
            type: EncryptedStreamImageType.newImage,
          );
        } catch (e) {
          appLogger.logRepository(
            'Error reading public image \${asset.id}',
            error: e.toString(),
          );
          return null;
        }
      });

      await for (final result in fileStream) {
        if (result == null) continue;
        yield result;
      }
    } catch (e) {
      appLogger.logRepository(
        'Error reading public gallery',
        error: e.toString(),
      );
      // Permission denied or gallery unavailable — yield nothing, let homepage load normally
    }
  }

  @override
  Future<bool> imageExists(String path, String fileName) async {
    final file = File('$path/$fileName');
    return await file.exists();
  }

  @override
  Future<bool> delete(List<StoragePath> images) async {
    final galleryImages = images.where((img) => img.assetId != null).toList();
    bool deleted = false;

    if (galleryImages.isNotEmpty) {
      final ids = galleryImages.map((img) => img.assetId!).toList();
      final deletedIds = await PhotoManager.editor.deleteWithIds(ids);

      // iOS may occasionally return an empty deleted-id list even when the
      // delete completed; confirm by checking whether assets still exist.
      final deletedSet = deletedIds.toSet();
      for (final id in ids) {
        if (deletedSet.contains(id)) {
          deleted = true;
          continue;
        }

        final stillExists = await AssetEntity.fromId(id) != null;
        if (!stillExists) {
          deleted = true;
        }
      }
    }

    final privateImages = images.where((img) => img.assetId == null).toList();
    for (final image in privateImages) {
      if (await image.file.exists()) {
        await image.file.delete();
        if (!deleted) deleted = true;
    } else {
      appLogger.logRepository(
        'File to delete',
          error: 'File does not exist: ${image.path}',
        );
      }
    }

    return deleted;
  }
  
  @override
  Future<StorageRenameResult> rename(
    String path,
    String oldFileName,
    String newFileName,
    {
    String? assetId,
    Uint8List? bytes,
    String? album,
  }
  ) async {
    if (assetId != null && Platform.isIOS) {
      if (bytes == null) {
        appLogger.logRepository(
          'Rename failed: missing image bytes for gallery asset',
          error: 'assetId: $assetId',
        );
        return const StorageRenameResult(success: false);
      }

      try {
        final newStem = newFileName.contains('.')
            ? newFileName.split('.').first
            : newFileName;
        final targetAlbum = album ?? Constants.appFolderName;

        await Gal.putImageBytes(
          bytes,
          name: newStem,
          album: targetAlbum,
        );

        final recentAssetId = await GalleryPathProvider.findMostRecentAssetId();
        if (recentAssetId != null) {
          await PhotoManager.editor.deleteWithIds([assetId]);

          // PhotoKit delete can complete asynchronously; verify before reporting success.
          var oldStillExists = await _assetExistsById(assetId);
          if (oldStillExists) {
            await Future<void>.delayed(const Duration(milliseconds: 250));
            oldStillExists = await _assetExistsById(assetId);
          }

          if (oldStillExists) {
            // Keep rename atomic: if old asset cannot be removed, rollback new one.
            await PhotoManager.editor.deleteWithIds([recentAssetId]);
            appLogger.logRepository(
              'Rename failed: old gallery asset still exists after delete attempt',
              error: 'oldAssetId: $assetId',
            );
            return const StorageRenameResult(success: false);
          }

          await AssetNameIndex.saveByAssetId(
            assetId: recentAssetId,
            fileName: newFileName,
          );
          return StorageRenameResult(success: true, newAssetId: recentAssetId);
        }

        appLogger.logRepository(
          'Rename warning: renamed asset saved but new asset id not found',
          error: 'oldAssetId: $assetId',
        );
        return const StorageRenameResult(success: false);
      } catch (e) {
        appLogger.logRepository(
          'Error renaming gallery asset',
          error: e.toString(),
        );
        return const StorageRenameResult(success: false);
      }
    }

    final oldFile = File('$path/$oldFileName');
    final newFile = File('$path/$newFileName');

    if (!await oldFile.exists()) {
      appLogger.logRepository(
        'Rename failed: Original file does not exist',
        error: 'File does not exist: ${oldFile.path}',
      );
      return const StorageRenameResult(success: false);
    }

    try {
      await oldFile.rename(newFile.path);
      return const StorageRenameResult(success: true);
    } catch (e) {
      appLogger.logRepository('Error renaming file', error: e.toString());
      return const StorageRenameResult(success: false);
    }
  }

  Future<bool> _assetExistsById(String assetId) async {
    final entity = await AssetEntity.fromId(assetId);
    return entity != null;
  }
}
