import 'dart:typed_data';

import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

abstract class StorageRepository {
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String path,
  });
  Stream<GalleryImage> readImages(String path);
}
