import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';

/// Contract for reading and watching the public gallery folder.
///
/// Android and iOS have fundamentally different mechanisms:
///   - Android: real filesystem path + [DirectoryWatcher].
///   - iOS: PhotoKit album (virtual) + polling.
///
/// Both implementations expose the same interface so the repository
/// is fully platform-agnostic.
abstract class PublicFolderDatasource {
  /// Loads the public folder and returns a fully populated [EncryptedFolder].
  ///
  /// Returns an empty [EncryptedFolder] with the correct path if the folder
  /// exists but contains no images yet (e.g. just created).
  /// Returns null if the folder does not exist or permissions are denied.
  Future<EncryptedFolder?> loadRoot();

  /// Watches the public folder for changes.
  ///
  /// Emits `null` whenever a change is detected and the in-memory state
  /// should be refreshed by calling [loadRoot] again.
  Stream<void> watchFolder(EncryptedFolder rootFolder);

  /// Creates the public folder if it does not already exist.
  ///
  /// Returns true on success, false on failure.
  Future<bool> createFolder();

  /// Returns all raw [AssetEntity] objects from the public folder.
  Future<List<AssetEntity>> getAssets();
}
