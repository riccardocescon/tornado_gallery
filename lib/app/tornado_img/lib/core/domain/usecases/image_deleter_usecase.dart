import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class ImageDeleterUsecase extends EncrpytionUseCase<void, ImageDeleterParams> {
  final StorageRepository storageRepo;

  ImageDeleterUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, void>> call(
    ImageDeleterParams params,
  ) async {
    try {
      await storageRepo.delete(params.path);
      return const Right(null);
    } catch (e) {
      appLogger.logUsecase('Error deleting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class ImageDeleterParams {
  final String path;

  ImageDeleterParams({required this.path});
}
