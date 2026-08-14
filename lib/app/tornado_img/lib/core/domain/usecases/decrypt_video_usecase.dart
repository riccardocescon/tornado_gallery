import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';

/// Decrypts an encrypted-video file (cosmetic mp4 + `uuid` ciphertext box,
/// see `video_box_codec.dart`) to a plaintext temp file. Orchestration only:
/// box parsing ([findVideoBox]) and the cipher ([processVideoPayload]) are
/// Tasks 1-2's, not reimplemented here.
class DecryptVideoUseCase extends EncryptionUseCase<File, DecryptVideoParams> {
  @override
  Future<Either<EncryptionFailure, File>> call(DecryptVideoParams params) {
    return guardEither('Error decrypting video', () async {
      var srcFile = File(params.encryptedPath);
      // A gallery-published video's stored path can be a virtual iOS album
      // path (no real filesystem entry) rather than a real file — resolve
      // the real asset file via PhotoKit instead, mirroring
      // DecryptImageUseCase's assetId fallback for images.
      if (!await srcFile.exists() && params.assetId != null) {
        final asset = await AssetEntity.fromId(params.assetId!);
        final resolved = await asset?.originFile ?? await asset?.file;
        if (resolved != null) srcFile = resolved;
      }
      final raf = await srcFile.open();
      final ParsedVideoBox? parsed;
      try {
        parsed = await findVideoBox(raf);
      } finally {
        await raf.close();
      }

      if (parsed == null) {
        return Left(EncryptionFailure.notAnEncryptedVideo());
      }

      final header = parsed.header;
      // Verify the password from 16 bytes before touching the (possibly
      // multi-GB) ciphertext — a wrong password fails here instead of after
      // writing a multi-GB garbage file.
      if (!matchesVideoKeyCheckValue(
        params.password,
        header.salt,
        header.kcv,
      )) {
        return Left(EncryptionFailure.wrongPassword());
      }

      final tempDir = Directory('${Directory.systemTemp.path}/tornado_video');
      await tempDir.create(recursive: true);
      final tempFile = File(
        '${tempDir.path}/${_stemOf(params.encryptedPath)}.${header.originalExt}',
      );

      try {
        await processVideoPayload(
          srcPath: srcFile.path,
          srcOffset: parsed.ciphertextOffset,
          length: header.originalSize,
          dstPath: tempFile.path,
          phrase: params.password,
          salt: header.salt,
        ).done;
      } catch (e) {
        if (await tempFile.exists()) await tempFile.delete();
        rethrow;
      }

      return Right(tempFile);
    });
  }

  String _stemOf(String path) {
    final base = FileNameUtils.basename(path);
    final dot = base.lastIndexOf('.');
    return dot <= 0 ? base : base.substring(0, dot);
  }
}

class DecryptVideoParams {
  final String encryptedPath;
  final String password;

  /// PhotoKit asset id, used to resolve a real file when [encryptedPath] is
  /// a virtual iOS gallery path (see [DecryptVideoUseCase.call]).
  final String? assetId;

  DecryptVideoParams({
    required this.encryptedPath,
    required this.password,
    this.assetId,
  });
}
