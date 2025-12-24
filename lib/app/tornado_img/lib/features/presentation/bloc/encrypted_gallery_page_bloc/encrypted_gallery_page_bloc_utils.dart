part of 'encrypted_gallery_page_bloc.dart';

class _EncryptedGalleryPageBlocUtils {
  // Helper methods for ordered insertion
  void insertFolderSorted(
    List<EncryptedEntity> entities,
    EncryptedFolder folder,
  ) {
    // Find position for folder (alphabetical order among folders)
    int insertIndex = 0;
    for (int i = 0; i < entities.length; i++) {
      if (entities[i] is EncryptedFolder) {
        final existingFolder = entities[i] as EncryptedFolder;
        if (folder.name.toLowerCase().compareTo(
              existingFolder.name.toLowerCase(),
            ) <
            0) {
          insertIndex = i;
          break;
        }
        insertIndex = i + 1;
      } else {
        // Hit first image, stop here
        break;
      }
    }
    entities.insert(insertIndex, folder);
  }

  void insertImageSorted(List<EncryptedEntity> entities, EncryptedImage image) {
    // Find position for image (after all folders, by date descending)
    int insertIndex = entities.length;

    // Skip all folders to find first image
    int firstImageIndex = 0;
    for (int i = 0; i < entities.length; i++) {
      if (entities[i] is EncryptedImage) {
        firstImageIndex = i;
        break;
      }
      firstImageIndex = i + 1;
    }

    // Find correct position among images (newest first)
    for (int i = firstImageIndex; i < entities.length; i++) {
      if (entities[i] is EncryptedImage) {
        final existingImage = entities[i] as EncryptedImage;
        if (image.date.isAfter(existingImage.date)) {
          insertIndex = i;
          break;
        }
      }
    }

    entities.insert(insertIndex, image);
  }
}
