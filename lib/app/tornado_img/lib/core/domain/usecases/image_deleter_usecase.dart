import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class ImageDeleterUsecase extends EncrpytionUseCase<bool, ImageDeleterParams> {
  final StorageRepository storageRepo;

  ImageDeleterUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(
    ImageDeleterParams params,
  ) async {
    try {
      final result = await storageRepo.delete(
        params.path,
        assetId: params.assetId,
      );
      return Right(result);
    } catch (e) {
      appLogger.logUsecase('Error deleting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class ImageDeleterParams {
  final String path;
  final String? assetId;

  ImageDeleterParams({required this.path, this.assetId});
}
