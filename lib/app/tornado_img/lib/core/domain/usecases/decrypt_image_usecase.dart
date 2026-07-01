import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

class DecryptImageUseCase
    extends EncryptionUseCase<BytesInfo, DecryptImageParams> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  DecryptImageUseCase({required this.imageRepo, required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, BytesInfo>> call(
    DecryptImageParams params,
  ) async {
    try {
      final decoded = await _decodeInput(params);

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

      final bytesInfo = BytesInfo(
        bytes: encoded,
        hash: ByteModeling.generateHash(encoded),
      );

      return Right(bytesInfo);
    } catch (e) {
      appLogger.logUsecase('Error decrypting image', error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }

  Future<ImageData?> _decodeInput(DecryptImageParams params) async {
    if (await params.file.exists()) {
      try {
        final decodedFromFile = await imageRepo.decode(params.file);
        if (decodedFromFile != null) return decodedFromFile;
      } on FileSystemException {
        // iOS temp export can disappear between exists() and read.
      }
    }

    final assetId = params.assetId;
    if (assetId == null) {
      return null;
    }

    final asset = await AssetEntity.fromId(assetId);
    if (asset == null) {
      return null;
    }

    final rawExt = params.file.path.split('.').last.toLowerCase();
    final extension = rawExt.isEmpty ? 'png' : rawExt;

    final bytes = await asset.originBytes;
    if (bytes != null) {
      final decodedFromBytes = await imageRepo.decodeBytes(
        bytes,
        extension: extension,
      );
      if (decodedFromBytes != null) return decodedFromBytes;
    }

    final fallbackFile = await asset.originFile ?? await asset.file;
    if (fallbackFile != null && await fallbackFile.exists()) {
      try {
        return await imageRepo.decode(fallbackFile);
      } on FileSystemException {
        return null;
      }
    }

    return null;
  }
}

class DecryptImageParams {
  final File file;
  final String password;
  final String? assetId;

  DecryptImageParams({
    required this.file,
    required this.password,
    this.assetId,
  });
}
