import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/data/datasources/storage/public_storage_datasource.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Android implementation of [PublicStorageDatasource].
///
/// Delegates to [Gal] which writes via MediaStore into `Pictures/<album>`.
/// No double-asset problem on Android because MediaStore manages the index.
class AndroidPublicStorageDatasource implements PublicStorageDatasource {
  @override
  Future<void> save({
    required String fileName,
    required String album,
    required Uint8List bytes,
  }) async {
    await Gal.putImageBytes(bytes, name: fileName, album: album);
  }

  @override
  Future<StorageRenameResult> rename({
    required String assetId,
    required String newFileName,
    required String album,
    required Uint8List bytes,
  }) async {
    // Android exposes a real filesystem path — the file rename is handled by
    // PrivateStorageDatasource via the File API. This method is only called
    // for iOS PhotoKit assets (assetId != null on iOS only).
    // If this is ever reached on Android, log and return failure.
    appLogger.logRepository(
      'AndroidPublicStorageDatasource.rename: unexpected call on Android',
      error: 'assetId: $assetId',
    );
    return const StorageRenameResult(success: false);
  }

  @override
  Future<bool> delete(List<String> assetIds) async {
    if (assetIds.isEmpty) return false;

    try {
      final deleted = await PhotoManager.editor.deleteWithIds(assetIds);
      final deletedSet = deleted.toSet();
      var success = false;

      for (final id in assetIds) {
        if (deletedSet.contains(id)) {
          success = true;
          continue;
        }
        // MediaStore delete can complete asynchronously — confirm by checking existence.
        final stillExists = await AssetEntity.fromId(id) != null;
        if (!stillExists) success = true;
      }

      return success;
    } catch (e) {
      appLogger.logRepository(
        'AndroidPublicStorageDatasource: error deleting assets',
        error: e.toString(),
      );
      return false;
    }
  }
}
