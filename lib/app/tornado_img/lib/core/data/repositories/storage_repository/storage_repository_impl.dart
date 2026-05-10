import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
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
      final assets = await GalleryPathProvider.getImagesFromPublicGallery();

      final fileStream = Stream.fromIterable(
        assets,
      ).asyncMap<EncryptedStreamImage?>((asset) async {
        try {
          final file = await asset.file;
          if (file == null) return null;

          final bytes = await file.readAsBytes();

          final encryptedImage = EncryptedImage(
            storagePath: StoragePath(
              path: file.path,
              isPrivateFolder: false,
              assetId: asset.id,
            ),
            date: asset.createDateTime,
            encryptedInfo: BytesInfo(
              bytes: bytes,
              hash: ByteModeling.generateHash(bytes),
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
      final deletes = await PhotoManager.editor.deleteWithIds(
        galleryImages.map((img) => img.assetId!).toList(),
      );
      deleted = deletes.isNotEmpty;
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
}
