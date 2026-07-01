import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

/// Deletes the folder at [DeleteFolderParams.relativePath] and its contents.
class DeleteFolderUseCase extends EncryptionUseCase<bool, DeleteFolderParams> {
  final StorageRepository storageRepo;

  DeleteFolderUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(DeleteFolderParams params) {
    return guardEither('Error deleting folder', () async {
      final relativePath = params.relativePath.trim();
      if (relativePath.isEmpty) {
        return Left(EncryptionFailure.encryptionError('Cannot delete root'));
      }

      final ok = await storageRepo.deleteFolder(
        isPrivate: params.isPrivate,
        relativePath: relativePath,
        contained: params.contained.map((img) => img.storagePath).toList(),
      );
      if (!ok) {
        return Left(
          EncryptionFailure.encryptionError('Folder could not be deleted'),
        );
      }
      return const Right(true);
    });
  }
}

class DeleteFolderParams {
  /// Folder path relative to the store root.
  final String relativePath;
  final bool isPrivate;

  /// Images contained in the folder (recursively), used to remove gallery assets.
  final List<EncryptedImage> contained;

  DeleteFolderParams({
    required this.relativePath,
    required this.isPrivate,
    this.contained = const [],
  });
}
