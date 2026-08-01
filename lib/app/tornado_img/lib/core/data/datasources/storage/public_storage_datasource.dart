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

  /// Saves the video file at [filePath] into the app's public gallery album.
  ///
  /// Path-based on purpose: an encrypted video's payload runs to gigabytes and
  /// must never be read into memory (see the video notes in `CLAUDE.md`).
  Future<void> saveVideo({required String filePath, required String album});

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

  // ── Folder operations ───────────────────────────────────────────────────────
  //
  // Gallery folders are modelled as albums whose name is the folder path
  // relative to the root album (e.g. `Vacanze/Mare`). On Android this maps to
  // a real `Pictures/TornadoGallery/Vacanze/Mare` directory; on iOS to a
  // PhotoKit album titled `TornadoGallery/Vacanze/Mare` (logical nesting).

  /// Creates the gallery folder identified by [relativePath]. Returns false
  /// if it already exists or on error.
  Future<bool> createFolder(String relativePath);

  /// Renames the gallery folder [oldRelativePath] to [newRelativePath].
  Future<bool> renameFolder(String oldRelativePath, String newRelativePath);

  /// Deletes the gallery folder at [relativePath]. [assetIds] are the IDs of
  /// the assets it contains, removed from PhotoKit/MediaStore.
  Future<bool> deleteFolder(String relativePath, List<String> assetIds);

  /// Yields the relative paths of all gallery subfolders (relative to the root
  /// album). On Android these map to real subdirectories; on iOS to PhotoKit
  /// albums named `<root>/<relative>`.
  Stream<String> listFolderPaths();
}
