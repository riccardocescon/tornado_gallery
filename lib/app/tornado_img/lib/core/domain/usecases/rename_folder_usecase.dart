import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Renames the folder at [RenameFolderParams.relativePath] to a sibling with
/// the new name, keeping its parent path unchanged.
class RenameFolderUsecase extends EncrpytionUseCase<bool, RenameFolderParams> {
  final StorageRepository storageRepo;

  RenameFolderUsecase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, bool>> call(
    RenameFolderParams params,
  ) async {
    final safeName = FileNameUtils.sanitizeFileStem(params.newName);
    if (params.newName.trim().isEmpty) {
      return Left(EncryptionFailure.encryptionError('Invalid folder name'));
    }

    final parts = params.relativePath.split('/')
      ..removeWhere((p) => p.trim().isEmpty);
    if (parts.isEmpty) {
      return Left(EncryptionFailure.encryptionError('Cannot rename root'));
    }
    parts.removeLast();
    final newRelativePath =
        parts.isEmpty ? safeName : '${parts.join('/')}/$safeName';

    if (newRelativePath == params.relativePath) {
      return const Right(true);
    }

    try {
      final ok = await storageRepo.renameFolder(
        isPrivate: params.isPrivate,
        oldRelativePath: params.relativePath,
        newRelativePath: newRelativePath,
      );
      if (!ok) {
        return Left(
          EncryptionFailure.encryptionError('Folder could not be renamed'),
        );
      }
      return const Right(true);
    } catch (e) {
      appLogger.logUsecase('Error renaming folder', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class RenameFolderParams {
  /// Folder path relative to the store root.
  final String relativePath;
  final String newName;
  final bool isPrivate;

  RenameFolderParams({
    required this.relativePath,
    required this.newName,
    required this.isPrivate,
  });
}
