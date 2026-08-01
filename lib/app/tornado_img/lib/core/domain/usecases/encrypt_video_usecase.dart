import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/data/video_crypto/cosmetic_mp4_builder.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';

/// Turns a plain video file into a cosmetic-mp4-plus-ciphertext-box file (see
/// `video_box_codec.dart` for the box layout) and saves it to private
/// storage. Orchestration only: the poster scrambling ([CosmeticMp4Builder]),
/// the box framing ([buildVideoBoxPrefix]) and the cipher
/// ([processVideoPayload]) are Tasks 1-3's, not reimplemented here.
class EncryptVideoUseCase
    extends EncryptionUseCase<EncryptedImage, EncryptVideoParams> {
  final CosmeticMp4Builder cosmeticBuilder;

  EncryptVideoUseCase({required this.cosmeticBuilder});

  @override
  Future<Either<EncryptionFailure, EncryptedImage>> call(
    EncryptVideoParams params,
  ) {
    return guardEither('Error encrypting video', () async {
      final originalSize = await params.file.length();
      if (originalSize > Constants.maxVideoBytes) {
        return Left(
          EncryptionFailure.fileTooLarge(originalSize, Constants.maxVideoBytes),
        );
      }

      final cosmetic = await cosmeticBuilder.build(
        posterBytes: params.posterBytes,
        password: params.password,
      );

      final safeStem = FileNameUtils.sanitizeFileStem(params.fileId);
      final outputFolder =
          params.destinationPath ??
          await GalleryPathProvider.getPrivateFolderPath();
      final outputFile = File('$outputFolder/$safeStem.mp4');
      await outputFile.parent.create(recursive: true);

      try {
        final salt = _randomSalt();
        final header = VideoBoxHeader(
          salt: salt,
          kcv: videoKeyCheckValue(params.password, salt),
          originalSize: originalSize,
          originalExt: FileNameUtils.extensionOf(params.file.path),
        );

        // Cosmetic bytes and the box prefix are small (a few KB); write them
        // in one shot, then stream the (possibly multi-GB) ciphertext
        // straight from source to destination in bounded memory.
        await outputFile.writeAsBytes(
          cosmetic + buildVideoBoxPrefix(header),
          flush: true,
        );

        await processVideoPayload(
          srcPath: params.file.path,
          srcOffset: 0,
          length: originalSize,
          dstPath: outputFile.path,
          phrase: params.password,
          salt: salt,
          append: true,
        ).done;
      } catch (e) {
        // A half-written file here is a corrupt .mp4 that a folder scan
        // would surface as a real (but broken) video — clean it up before
        // letting guardEither convert the error into a Left.
        if (await outputFile.exists()) await outputFile.delete();
        rethrow;
      }

      return Right(
        EncryptedImage(
          storagePath: StoragePath(
            path: outputFile.path,
            isPrivateFolder: true,
            assetId: null,
          ),
          // The cosmetic bytes are the only part worth hashing here — the
          // ciphertext can be multi-GB, and hashing it would defeat the
          // point of streaming it in bounded memory.
          encryptedInfo: BytesInfo(
            bytes: cosmetic,
            hash: ByteModeling.generateHash(cosmetic),
          ),
          date: DateTime.now(),
        ),
      );
    });
  }

  Uint8List _randomSalt() {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List.generate(VideoBoxHeader.saltLength, (_) => rnd.nextInt(256)),
    );
  }
}

class EncryptVideoParams {
  final File file;
  final String password;
  final String fileId;

  /// jpeg/png thumbnail of the source video (max 720px long side —
  /// [CosmeticMp4Builder] downscales further if needed). Acquiring this from
  /// `photo_manager`/`AssetEntity` is device-only, so callers fetch it and
  /// pass the bytes in rather than this use case reaching for the plugin
  /// itself — the only seam this use case needs to stay unit-testable.
  final Uint8List posterBytes;

  /// Absolute private-storage folder to save into. Defaults to the app's
  /// private `encrypted/` root when null (mirrors `EncryptImageUseCase`).
  final String? destinationPath;

  EncryptVideoParams({
    required this.file,
    required this.password,
    required this.fileId,
    required this.posterBytes,
    this.destinationPath,
  });
}
