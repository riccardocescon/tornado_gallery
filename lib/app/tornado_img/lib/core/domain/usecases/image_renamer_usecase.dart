import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

class ImageRenamerUseCase
  extends EncryptionUseCase<StorageRenameResult, ImageRenamerParams> {
  final StorageRepository storageRepo;

  ImageRenamerUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, StorageRenameResult>> call(
    ImageRenamerParams params,
  ) {
    return guardEither('Error renaming image', () async {
      final result = await storageRepo.rename(
        params.path,
        params.oldFileName,
        params.newFileName,
        assetId: params.assetId,
        bytes: params.bytes,
        album: params.album,
      );
      return Right(result);
    });
  }
}

class ImageRenamerParams {
  final String path;
  final String oldFileName;
  final String newFileName;
  final String? assetId;
  final Uint8List? bytes;
  final String? album;

  ImageRenamerParams({
    required this.path,
    required this.oldFileName,
    required this.newFileName,
    this.assetId,
    this.bytes,
    this.album,
  });
}
