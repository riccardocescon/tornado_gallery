import 'dart:io';

import 'package:dartz/dartz.dart';
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
      final srcFile = File(params.encryptedPath);
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
          srcPath: params.encryptedPath,
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

  DecryptVideoParams({required this.encryptedPath, required this.password});
}
