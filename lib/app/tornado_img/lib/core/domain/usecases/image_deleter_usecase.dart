import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

class ImageDeleterUseCase extends EncryptionUseCase<bool, ImageDeleterParams> {
  final StorageRepository storageRepo;

  ImageDeleterUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(ImageDeleterParams params) {
    return guardEither('Error deleting image', () async {
      final result = await storageRepo.delete(
        params.images.map((img) => img.storagePath).toList(),
      );
      return Right(result);
    });
  }
}

class ImageDeleterParams {
  final List<EncryptedImage> images;

  ImageDeleterParams({required this.images});
}
