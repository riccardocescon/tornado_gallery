import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

class ImageSaverUseCase extends EncryptionUseCase<void, ImageSaverParams> {
  final StorageRepository storageRepo;

  ImageSaverUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, void>> call(ImageSaverParams params) async {
    try {

      // For the private folder, the name must contain the extension, but for the gallery, it must not
      final fixedFileName =
          params.path != null
              ? params.fileName
              : params.fileName.split('.').first;

      await storageRepo.save(
        bytes: params.bytes,
        fileName: fixedFileName,
        path: params.path,
        album: params.album,
      );
      return const Right(null);
    } catch (e) {
      appLogger.logUsecase('Error saving image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class ImageSaverParams {
  final Uint8List bytes;
  final String fileName;
  final String? path;
  final String? album;

  ImageSaverParams._({
    required this.bytes,
    required this.fileName,
    required this.path,
    required this.album,
  });

  factory ImageSaverParams.gallery({
    required Uint8List bytes,
    required String fileName,
    String? album,
  }) {
    return ImageSaverParams._(
      bytes: bytes,
      fileName: fileName,
      album: album,
      path: null,
    );
  }

  factory ImageSaverParams.appFolder({
    required Uint8List bytes,
    required String fileName,
    required String path,
  }) {
    return ImageSaverParams._(
      bytes: bytes,
      fileName: fileName,
      path: path,
      album: null,
    );
  }
}
