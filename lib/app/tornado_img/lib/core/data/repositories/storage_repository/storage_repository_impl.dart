import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
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
  }) async {
    try {
      if (path == null) {
        await Gal.putImageBytes(bytes, name: fileName);
        return;
      }
      
      final file = File('$path/$fileName');

      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    } catch (e) {
      appLogger.logRepository('Error saving image', error: e.toString());
    }
  }

  @override
  Stream<EncryptedStreamImage> readImages(String path) async* {
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
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    } else {
      appLogger.logRepository(
        'File to delete',
        error: 'File does not exist: $path',
      );
    }
  }
}
