import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

class DecryptImageUseCase
    extends EncrpytionUseCase<BytesInfo, DecryptImageParams> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  DecryptImageUseCase({required this.imageRepo, required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, BytesInfo>> call(
    DecryptImageParams params,
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

      final bytesInfo = BytesInfo(
        bytes: encoded,
        hash: ByteModeling.generateHash(encoded),
      );

      return Right(bytesInfo);
    } catch (e) {
      appLogger.logUsecase('Error encrypting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class DecryptImageParams {
  final File file;
  final String password;

  DecryptImageParams({required this.file, required this.password});
}
