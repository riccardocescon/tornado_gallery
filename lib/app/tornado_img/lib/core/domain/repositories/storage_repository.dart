import 'dart:typed_data';

import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';

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

  // ── Folder operations ───────────────────────────────────────────────────────
  //
  // [relativePath] is the folder path relative to the store root (the private
  // `encrypted/` dir, or the gallery root album). Empty string == root.

  /// Creates the folder [relativePath] in the private store or gallery.
  Future<bool> createFolder({
    required bool isPrivate,
    required String relativePath,
  });

  /// Renames folder [oldRelativePath] to [newRelativePath].
  Future<bool> renameFolder({
    required bool isPrivate,
    required String oldRelativePath,
    required String newRelativePath,
  });

  /// Deletes folder [relativePath]. [contained] are the storage paths of the
  /// images within it (used to remove gallery assets).
  Future<bool> deleteFolder({
    required bool isPrivate,
    required String relativePath,
    required List<StoragePath> contained,
  });

  /// Yields relative paths of all subdirectories inside [rootPath].
  Stream<String> readPrivateFolderPaths(String rootPath);

  /// Yields relative paths of all public gallery subfolders (relative to the
  /// public root album). Used to surface folders that may still be empty.
  Stream<String> readPublicFolderPaths();

  /// Moves [images] into the folder [targetRelativePath]. Returns the moved
  /// images' new [StoragePath]s (private store only; gallery moves are
  /// reported via [StorageMoveResult]).
  Future<StorageMoveResult> moveImages({
    required List<EncryptedImage> images,
    required String targetRelativePath,
  });
}

/// Outcome of a [StorageRepository.moveImages] call.
class StorageMoveResult {
  final bool success;

  /// New storage paths for successfully moved private images, keyed by their
  /// original absolute path.
  final Map<String, String> movedPrivatePaths;

  const StorageMoveResult({
    required this.success,
    this.movedPrivatePaths = const {},
  });
}
