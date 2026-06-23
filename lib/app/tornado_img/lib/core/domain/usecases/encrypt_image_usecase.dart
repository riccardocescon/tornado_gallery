import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';

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

      final safeStem = FileNameUtils.sanitizeFileStem(params.fileId);
      final fileName = '$safeStem.png';
      final saveName = params.settings.galleryVisible ? safeStem : fileName;

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

      await storageRepo.save(
        bytes: encoded,
        fileName: saveName,
        path: params.settings.destinationPath,
        album: GalleryPathProvider.getPublicAlbumName(
          params.settings.publicRelativeAlbum,
        ),
      );

      
      final isGalleryVisible = params.settings.galleryVisible;
      final String albumName = GalleryPathProvider.getPublicAlbumName(
        params.settings.publicRelativeAlbum,
      );
      final String? encryptedAssetId =
          isGalleryVisible
              ? await GalleryPathProvider.findMostRecentAssetId(
                  albumName: albumName,
                )
              : null;

      if (params.settings.deleteOriginals) {
        storageRepo.delete([
          StoragePath(
            path: params.file.path,
            isPrivateFolder: !isGalleryVisible,
            assetId: params.assetId,
          ),
        ]);
      }

      String? outputFolder = params.settings.destinationPath;
      if (outputFolder == null && isGalleryVisible) {
        // On iOS there's no stable filesystem path for PhotoKit albums.
        // Use the album name as a virtual path so storeRelativeDir resolves
        // the subfolder correctly (matches how IosPublicFolderDatasource
        // assigns paths in _attachSubfolders on reload).
        outputFolder = Platform.isIOS
            ? albumName
            : await GalleryPathProvider.getPublicFolderPath(
                relative: params.settings.publicRelativeAlbum,
              );
      }

      final encryptedFile = File('$outputFolder/$fileName');
      final encryptedImage = EncryptedImage(
        storagePath: StoragePath(
          isPrivateFolder: !isGalleryVisible,
        path: encryptedFile.path,
          assetId: encryptedAssetId,
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

  Future<ImageData?> _decodeInput(EncryptImageParams params) async {
    if (await params.file.exists()) {
      try {
        final decodedFromFile = await imageRepo.decode(params.file);
        if (decodedFromFile != null) return decodedFromFile;
      } on FileSystemException {
        // iOS picker temp file can disappear between exists() and read.
        // Fall back to PhotoManager asset bytes below.
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

    final ext = params.file.path.split('.').last.toLowerCase();
    final bytes = await asset.originBytes;
    if (bytes != null) {
      return imageRepo.decodeBytes(bytes, extension: ext);
    }

    final fallbackFile = await asset.originFile ?? await asset.file;
    if (fallbackFile != null && await fallbackFile.exists()) {
      return imageRepo.decode(fallbackFile);
    }

    return null;
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
