import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/data/video_crypto/cosmetic_mp4_builder.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';

/// Turns a plain video file into a cosmetic-mp4-plus-ciphertext-box file (see
/// `video_box_codec.dart` for the box layout) and saves it to private storage,
/// or to the public gallery when [EncryptVideoParams.publicRelativeAlbum] is
/// set. Orchestration only: the poster scrambling ([CosmeticMp4Builder]),
/// the box framing ([buildVideoBoxPrefix]) and the cipher
/// ([processVideoPayload]) are Tasks 1-3's, not reimplemented here.
class EncryptVideoUseCase
    extends EncryptionUseCase<EncryptedImage, EncryptVideoParams> {
  final CosmeticMp4Builder cosmeticBuilder;
  final StorageRepository storageRepo;

  EncryptVideoUseCase({
    required this.cosmeticBuilder,
    required this.storageRepo,
  });

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
      final fileName = '$safeStem.mp4';
      final rel = params.publicRelativeAlbum;

      // A gallery save hands the finished file to the platform by path, so it
      // is built in a temp dir first and deleted once handed over. Deliberately
      // not the playback temp dir (`tornado_video`), which VideoPlayerPage
      // wipes wholesale before every run.
      final outputFolder =
          rel != null
              ? '${Directory.systemTemp.path}/tornado_video_enc'
              : params.destinationPath ??
                  await GalleryPathProvider.getPrivateFolderPath();
      final outputFile = File('$outputFolder/$fileName');
      await outputFile.parent.create(recursive: true);

      try {
        final salt = _randomSalt();

        // Write the cosmetic bytes first so the file on disk is real from
        // this point on — if anything below throws (including a malformed
        // header caught synchronously by buildVideoBoxPrefix), the catch
        // block below has a genuine partial file to clean up.
        await outputFile.writeAsBytes(cosmetic.mp4, flush: true);

        // The scrambled poster rides along as its own `uuid` box so folder
        // scans can render a thumbnail from a few hundred KB instead of
        // reading back a file that may be gigabytes long.
        final posterBox = buildPosterBox(cosmetic.posterPng);

        final header = VideoBoxHeader(
          salt: salt,
          kcv: videoKeyCheckValue(params.password, salt),
          originalSize: originalSize,
          originalExt: FileNameUtils.extensionOf(params.file.path),
        );
        final prefix = buildVideoBoxPrefix(header);

        final raf = await outputFile.open(mode: FileMode.writeOnlyAppend);
        await raf.writeFrom(posterBox);
        await raf.writeFrom(prefix);
        await raf.close();

        // Stream the (possibly multi-GB) ciphertext straight from source to
        // destination in bounded memory.
        await processVideoPayload(
          srcPath: params.file.path,
          srcOffset: 0,
          length: originalSize,
          dstPath: outputFile.path,
          phrase: params.password,
          salt: salt,
          append: true,
        ).done;

        if (rel != null) {
          await storageRepo.saveVideo(
            filePath: outputFile.path,
            album: GalleryPathProvider.getPublicAlbumName(rel),
          );
          await outputFile.delete();
        }
      } catch (e) {
        // A half-written file here is a corrupt .mp4 that a folder scan
        // would surface as a real (but broken) video — clean it up before
        // letting guardEither convert the error into a Left.
        if (await outputFile.exists()) await outputFile.delete();
        rethrow;
      }

      // On a gallery save the file no longer lives at outputFile.path — it was
      // handed to the platform and the temp copy deleted. Record where the
      // store put it, mirroring EncryptImageUseCase's public branch (the album
      // name stands in when there is no real filesystem path).
      //
      // ponytail: Gal appends a numeric suffix when the name is taken, so a
      // collision leaves this path one character off the real file. The folder
      // watcher's next scan replaces the entry with the real one.
      final storedPath =
          rel != null
              ? '${await GalleryPathProvider.getPublicFolderPath(relative: rel) ?? GalleryPathProvider.getPublicAlbumName(rel)}/$fileName'
              : outputFile.path;

      return Right(
        EncryptedImage(
          storagePath: StoragePath(
            path: storedPath,
            isPrivateFolder: rel == null,
            assetId: null,
          ),
          // The scrambled poster stands in for the "encrypted bytes" of an
          // image: it is what the UI renders, and it is small. Hashing the
          // ciphertext instead would defeat the point of streaming it in
          // bounded memory.
          encryptedInfo: BytesInfo(
            bytes: cosmetic.posterPng,
            hash: ByteModeling.generateHash(cosmetic.posterPng),
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
  /// Ignored when [publicRelativeAlbum] is set.
  final String? destinationPath;

  /// Gallery folder relative to the public root album ('' = root album). When
  /// **non-null** the encrypted video goes to the public gallery instead of
  /// private storage — so the discriminator is `!= null`, not `isEmpty`.
  ///
  /// Deliberately no `Platform` check in here: the caller decides which
  /// platforms may publish (v1: Android only, see `GalleryBloc`), which keeps
  /// this branch unit-testable.
  final String? publicRelativeAlbum;

  EncryptVideoParams({
    required this.file,
    required this.password,
    required this.fileId,
    required this.posterBytes,
    this.destinationPath,
    this.publicRelativeAlbum,
  });
}
