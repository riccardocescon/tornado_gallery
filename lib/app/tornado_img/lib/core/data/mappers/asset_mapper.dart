import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

/// Maps a [AssetEntity] from PhotoManager to an [EncryptedImage].
/// Used exclusively for public gallery assets (both Android and iOS).
class AssetMapper {
  const AssetMapper._();

  /// Converts a [AssetEntity] to an [EncryptedImage].
  ///
  /// [folderPath] is the resolved absolute path of the parent folder used
  /// as the storagePath for the image. On iOS this may be a virtual path.
  ///
  /// Returns null if the asset file cannot be read.
  static Future<EncryptedImage?> fromAsset({
    required AssetEntity asset,
    required String folderPath,
  }) async {
    try {
      final file = await asset.file;
      if (file == null) return null;

      // Never `readAsBytes()` here: a gallery-visible encrypted video is mostly
      // ciphertext and can run to gigabytes. This reads the poster box for
      // videos and the whole file only for images — same helper the private and
      // Android-subfolder scans use.
      final bytes = await readMediaPreviewBytes(file);
      if (bytes == null) return null;
      final hash = ByteModeling.generateHash(bytes);
      final filePath =
          '$folderPath${Platform.pathSeparator}${FileNameUtils.basename(file.path)}';

      return EncryptedImage(
        storagePath: StoragePath(
          path: filePath,
          isPrivateFolder: false,
          assetId: asset.id,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: asset.createDateTime,
      );
    } catch (_) {
      return null;
    }
  }
}
