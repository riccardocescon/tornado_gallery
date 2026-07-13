import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';

/// Creates a folder named [CreateFolderParams.name] under
/// [CreateFolderParams.parentRelativePath] in the private store or gallery.
class CreateFolderUseCase extends EncryptionUseCase<bool, CreateFolderParams> {
  final StorageRepository storageRepo;

  CreateFolderUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(CreateFolderParams params) {
    return guardEither('Error creating folder', () async {
      final safeName = FileNameUtils.sanitizeFileStem(params.name);
      if (safeName.isEmpty ||
          safeName == 'image' && params.name.trim().isEmpty) {
        return Left(EncryptionFailure.encryptionError('Invalid folder name'));
      }

      final parent = params.parentRelativePath.trim();
      final relativePath = parent.isEmpty ? safeName : '$parent/$safeName';

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
    });
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
