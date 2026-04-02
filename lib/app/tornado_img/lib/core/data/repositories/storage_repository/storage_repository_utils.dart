part of 'storage_repository_impl.dart';

class StorageRepositoryUtils {
  // Helper to yield all images in this directory and subdirectories
  Stream<EncryptedImage> readAllImagesRecursively(Directory dir) async* {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final galleryImage = await _fileToGalleryImage(entity);
        if (galleryImage != null) yield galleryImage;
      }

      if (entity is Directory) {
        yield* readAllImagesRecursively(entity);
      }
    }
  }

  Future<EncryptedImage?> _fileToGalleryImage(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (['png', 'jpg', 'jpeg'].contains(ext)) {
      final lastModified = await file.lastModified();
      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);
      final galleryImage = EncryptedImage(
        path: file.path,
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: lastModified,
      );
      appLogger.logRepository('Found image: ${file.path}');
      return galleryImage;
    }

    appLogger.logRepository('File is not supported: ${file.path}');
    return null;
  }
}
