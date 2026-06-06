import 'dart:io';

import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

/// Maps a [File] from the filesystem to an [EncryptedImage].
/// Used exclusively for private (encrypted) folder files.
class FileMapper {
  const FileMapper._();

  /// Converts a [File] to an [EncryptedImage].
  ///
  /// [isPrivateFolder] should always be true when reading from the app sandbox.
  ///
  /// Returns null if the file cannot be read.
  static Future<EncryptedImage?> fromFile({
    required File file,
    required bool isPrivateFolder,
  }) async {
    try {
      final date = file.statSync().modified;
      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);

      return EncryptedImage(
        storagePath: StoragePath(
          path: file.path,
          isPrivateFolder: isPrivateFolder,
          assetId: null,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: date,
      );
    } catch (_) {
      return null;
    }
  }
}
