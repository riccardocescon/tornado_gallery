import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class EncryptImageUseCase
    extends EncrpytionUseCase<GalleryImage, EncryptImageParams> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  EncryptImageUseCase({required this.imageRepo, required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, GalleryImage>> call(
    EncryptImageParams params,
  ) async {
    try {
      final decoded = await imageRepo.decode(params.file);

      if (decoded == null) {
        return Left(
          EncryptionFailure.unsupportedExtension(
            params.file.path.split('.').last,
          ),
        );
      }

      final encrypted = await imageRepo.encrypt(decoded, params.password);

      final encoded = await imageRepo.encode(encrypted);

      if (encoded == null) {
        return Left(EncryptionFailure.encryptionError('Encoding failed'));
      }

      await storageRepo.save(
        bytes: encoded,
        fileName: '${params.fileId}.png',
        path: params.path,
      );

      final encryptedFile = File('${params.path}/${params.fileId}.png');
      final encryptedImage = GalleryImage(
        id: params.fileId,
        file: encryptedFile,
        date: DateTime.now(),
      );

      return Right(encryptedImage);
    } catch (e) {
      appLogger.logUsecase('Error encrypting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class EncryptImageParams {
  final File file;
  final String password;
  final String fileId;
  final String path;

  EncryptImageParams({
    required this.file,
    required this.password,
    required this.fileId,
    required this.path,
  });
}
