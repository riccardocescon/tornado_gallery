part of 'storage_repository_impl.dart';

class StorageRepositoryUtils {
  // Helper to yield all images in this directory and subdirectories
  Stream<GalleryImage> readAllImagesRecursively(Directory dir) async* {
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

  Future<GalleryImage?> _fileToGalleryImage(File file) async {
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
      return galleryImage;
    }

    appLogger.logRepository('File is not supported: ${file.path}');
    return null;
  }
}
