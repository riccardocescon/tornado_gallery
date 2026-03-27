import 'dart:io';
import 'dart:typed_data';
import 'package:tornado_img_app/core/domain/repositories/storage_repository_impl.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String path,
  }) async {

    final file = File('$path/$fileName');

    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  @override
  Stream<GalleryImage> readImages(String path) async* {
    final dir = Directory(path);
    appLogger.logRepository('Reading images from $path');
    if (!await dir.exists()) {
      appLogger.logRepository('Directory does not exist: $path');
      return;
    }

    final filesSteam = dir.list();
    await for (final file in filesSteam) {
      if (file is File) {
        final ext = file.path.split('.').last.toLowerCase();
        if (['png', 'jpg', 'jpeg'].contains(ext)) {
          final fileId = file.path.split('/').last.split('.').first;
          final lastModified = await file.lastModified();
          final galleryImage = GalleryImage(
            id: fileId,
            date: lastModified,
            file: file,
          );
          appLogger.logRepository('Found image: ${file.path}');
          yield galleryImage;
        }
        continue;
      }

      if (file is Directory) {
        appLogger.logRepository('Found directory: ${file.path}');
        yield* readImages(file.path);
      }
    }
  }
}
