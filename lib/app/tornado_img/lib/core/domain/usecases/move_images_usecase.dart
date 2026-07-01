import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

/// Moves the given images into the folder [MoveImagesParams.targetRelativePath].
///
/// Returns the [StorageMoveResult] so the caller can update the in-memory
/// model with the new private paths.
class MoveImagesUseCase
    extends EncryptionUseCase<StorageMoveResult, MoveImagesParams> {
  final StorageRepository storageRepo;

  MoveImagesUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, StorageMoveResult>> call(
    MoveImagesParams params,
  ) {
    return guardEither('Error moving images', () async {
      if (params.images.isEmpty) {
        return const Right(StorageMoveResult(success: false));
      }

      final result = await storageRepo.moveImages(
        images: params.images,
        targetRelativePath: params.targetRelativePath,
      );
      if (!result.success) {
        return Left(EncryptionFailure.encryptionError('No images were moved'));
      }
      return Right(result);
    });
  }
}

class MoveImagesParams {
  final List<EncryptedImage> images;

  /// Destination folder path relative to the store root ('' for root).
  final String targetRelativePath;

  MoveImagesParams({
    required this.images,
    required this.targetRelativePath,
  });
}
