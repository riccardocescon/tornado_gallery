import 'dart:typed_data';

import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';

/// Contract for saving, renaming and deleting images in the public gallery.
///
/// Android: uses [Gal] which writes to `Pictures/<AppName>` via MediaStore.
/// iOS: uses [PhotoManager] directly to avoid the double-asset bug caused by
///      Gal's internal save-to-Recents → copy-to-album two-step.
abstract class PublicStorageDatasource {
  /// Saves [bytes] as [fileName] into the app's public gallery album.
  Future<void> save({
    required String fileName,
    required String album,
    required Uint8List bytes,
  });

  /// Renames a public gallery asset identified by [assetId].
  ///
  /// On iOS, PhotoKit has no rename API — the implementation saves a new
  /// asset with [newFileName] and deletes the old one atomically.
  ///
  /// Returns a [StorageRenameResult] with the new asset ID on success.
  Future<StorageRenameResult> rename({
    required String assetId,
    required String newFileName,
    required String album,
    required Uint8List bytes,
  });

  /// Deletes all public gallery assets whose IDs are in [assetIds].
  ///
  /// Returns true if at least one asset was successfully deleted.
  Future<bool> delete(List<String> assetIds);
}
