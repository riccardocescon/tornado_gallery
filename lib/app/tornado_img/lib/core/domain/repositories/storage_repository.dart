import 'dart:typed_data';

import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

abstract class StorageRepository {
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String? path,
    required String? album,
  });
  Stream<EncryptedStreamImage> readPrivateImages(String path);
  Stream<EncryptedStreamImage> readPublicGalleryImages();
  Future<bool> imageExists(String path, String fileName);
  Future<void> delete(String path, {String? assetId});
}
