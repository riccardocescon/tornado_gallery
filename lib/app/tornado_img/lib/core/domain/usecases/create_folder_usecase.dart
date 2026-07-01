import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Creates a folder named [CreateFolderParams.name] under
/// [CreateFolderParams.parentRelativePath] in the private store or gallery.
class CreateFolderUsecase extends EncrpytionUseCase<bool, CreateFolderParams> {
  final StorageRepository storageRepo;

  CreateFolderUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(
    CreateFolderParams params,
  ) async {
    final safeName = FileNameUtils.sanitizeFileStem(params.name);
    if (safeName.isEmpty || safeName == 'image' && params.name.trim().isEmpty) {
      return Left(EncryptionFailure.encryptionError('Invalid folder name'));
    }

    final parent = params.parentRelativePath.trim();
    final relativePath = parent.isEmpty ? safeName : '$parent/$safeName';

    try {
      final created = await storageRepo.createFolder(
        isPrivate: params.isPrivate,
        relativePath: relativePath,
      );
      if (!created) {
        return Left(
          EncryptionFailure.encryptionError(
            'Folder already exists or could not be created',
          ),
        );
      }
      return const Right(true);
    } catch (e) {
      appLogger.logUsecase('Error creating folder', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class CreateFolderParams {
  /// Path of the parent folder relative to the store root ('' for root).
  final String parentRelativePath;
  final String name;
  final bool isPrivate;

  CreateFolderParams({
    required this.parentRelativePath,
    required this.name,
    required this.isPrivate,
  });
}
