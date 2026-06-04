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
        storagePath: StoragePath(
          path: file.path,
          isPrivateFolder: true,
          assetId: null,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: lastModified,
      );
      appLogger.logRepository('Found image: ${file.path}');
      return galleryImage;
    }

    appLogger.logRepository('File is not supported: ${file.path}');
    return null;
  }

  Future<bool> renameFileAndroid({
    required String path,
    required String oldFileName,
    required String newFileName,
  }) async {
    final oldFile = File('$path/$oldFileName');
    final newFile = File('$path/$newFileName');

    if (!await oldFile.exists()) {
      appLogger.logRepository(
        'Rename failed: Original file does not exist',
        error: 'File does not exist: ${oldFile.path}',
      );
      return false;
    }

    try {
      await oldFile.rename(newFile.path);
      return true;
    } catch (e) {
      appLogger.logRepository('Error renaming file', error: e.toString());
      return false;
    }
  }
}
