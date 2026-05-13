import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class ImageRenamerUsecase extends EncrpytionUseCase<bool, ImageRenamerParams> {
  final StorageRepository storageRepo;

  ImageRenamerUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(
    ImageRenamerParams params,
  ) async {
    try {
      final result = await storageRepo.rename(
        params.path,
        params.oldFileName,
        params.newFileName,
      );
      return Right(result);
    } catch (e) {
      appLogger.logUsecase('Error deleting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class ImageRenamerParams {
  final String path;
  final String oldFileName;
  final String newFileName;

  ImageRenamerParams({
    required this.path,
    required this.oldFileName,
    required this.newFileName,
  });
}
