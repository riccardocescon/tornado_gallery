part of '../encrypted_gallery_page.dart';

/// Constants for the EncryptedGalleryPage
class EncryptedGalleryPageConstants {
  // UI Constants
  static const String defaultTitle = 'Local Gallery';
  static const String deleteDialogTitle = 'Delete Folder';
  static const String deleteDialogContent =
      'Are you sure you want to delete this folder and all its files and subfolders? This action cannot be undone.';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';
  static const String folderPrefix = 'Folder: ';

  // Grid constants
  static const int gridCrossAxisCount = 3;
  static const double gridSpacing = 4.0;
  static const double gridPadding = 8.0;

  // Icon sizes
  static const double appBarIconSize = 20.0;
  static const double folderIconSize = 48.0;
  static const double decryptIconSize = 16.0;

  // Progress indicator
  static const double progressIndicatorStroke = 2.0;

  // Folder display
  static const double folderPadding = 6.0;
  static const int pathSegmentsToShow = 3;
}
