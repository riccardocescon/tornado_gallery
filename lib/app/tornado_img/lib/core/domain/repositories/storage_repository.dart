import 'dart:typed_data';

import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

class StorageRenameResult {
  final bool success;
  final String? newAssetId;

  const StorageRenameResult({required this.success, this.newAssetId});
}

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
  Future<StorageRenameResult> rename(
    String path,
    String oldFileName,
    String newFileName, {
    String? assetId,
    Uint8List? bytes,
    String? album,
  });
  Future<bool> delete(List<StoragePath> images);
}
