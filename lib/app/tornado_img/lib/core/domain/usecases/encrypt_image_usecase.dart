import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/encryption_settings.dart';

class EncryptImageUseCase
    extends EncrpytionUseCase<EncryptedImage, EncryptImageParams> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  EncryptImageUseCase({required this.imageRepo, required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, EncryptedImage>> call(
    EncryptImageParams params,
  ) async {

    try {

      final fileName = '${params.fileId}.png';

      final decoded = await imageRepo.decode(params.file);

      if (decoded == null) {
        return Left(
          EncryptionFailure.unsupportedExtension(
            params.file.path.split('.').last,
          ),
        );
      }

      final encrypted = await imageRepo.encrypt(decoded, params.password);

      final encoded = await imageRepo.encode(encrypted);

      if (encoded == null) {
        return Left(EncryptionFailure.encryptionError('Encoding failed'));
      }

      await storageRepo.save(
        bytes: encoded,
        fileName: fileName,
        path: params.settings.destinationPath,
        album: Constants.appFolderName,
      );

      
      final isGalleryVisible = params.settings.galleryVisible;

      if (params.settings.deleteOriginals) {
        storageRepo.delete([
          StoragePath(
            path: params.file.path,
            isPrivateFolder: !isGalleryVisible,
            assetId: params.assetId,
          ),
        ]);
      }

      final encryptedFile = File(
        '${params.settings.outputFolder}/${params.fileId}.png',
      );
      final encryptedImage = EncryptedImage(
        storagePath: StoragePath(
          isPrivateFolder: !isGalleryVisible,
        path: encryptedFile.path,
          assetId: isGalleryVisible ? params.assetId : null,
        ),
        encryptedInfo: BytesInfo(
          bytes: encoded,
          hash: ByteModeling.generateHash(encoded),
        ),
        date: DateTime.now(),
      );

      return Right(encryptedImage);
    } catch (e) {
      appLogger.logUsecase('Error encrypting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

class EncryptImageParams {
  final File file;
  final String password;
  final String fileId;
  final EncryptionSettings settings;
  final String? assetId;

  EncryptImageParams({
    required this.file,
    required this.password,
    required this.fileId,
    required this.settings,
    this.assetId,
  });
}
