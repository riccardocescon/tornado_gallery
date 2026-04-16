import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class ImageSaverUsecase extends EncrpytionUseCase<void, ImageSaverParams> {
  final StorageRepository storageRepo;

  ImageSaverUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, void>> call(ImageSaverParams params) async {
    try {
      final fixedFileName = params.fileName.split('.').first;

      await storageRepo.save(
        bytes: params.bytes,
        fileName: fixedFileName,
        path: null,
        album: null,
      );
      return const Right(null);
    } catch (e) {
      appLogger.logUsecase('Error saving image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class ImageSaverParams {
  final Uint8List bytes;
  final String fileName;

  ImageSaverParams({required this.bytes, required this.fileName});
}
