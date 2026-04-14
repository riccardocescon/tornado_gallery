import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

class GalleryReaderUsecase
    extends GalleryReaderUseCase<EncryptedStreamImage, void> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  GalleryReaderUsecase({required this.imageRepo, required this.storageRepo});

  @override
  Stream<Either<DecryptionFailure, EncryptedStreamImage>> call(
    void params,
  ) async* {
    try {
      // Stream per la cartella privata (crittografata)
      final privateFolderPath =
          await GalleryPathProvider.getEncryptedFolderPath();
      yield* storageRepo
          .readPrivateImages(privateFolderPath)
          .asyncMap((image) => Right(image));

      // Stream per l'album pubblico TornadoGallery
      yield* _readPublicGalleryImages();
    } catch (e) {
      appLogger.logUsecase('Error reading gallery', error: e.toString());
      yield Left(DecryptionFailure.decryptionError(e.toString()));
    }
  }

  /// Stream per leggere le immagini dall'album TornadoGallery
  Stream<Either<DecryptionFailure, EncryptedStreamImage>>
  _readPublicGalleryImages() async* {
    try {
      final assets = await GalleryPathProvider.getImagesFromPublicGallery();

      final fileStream = Stream.fromIterable(
        assets,
      ).asyncMap<Either<DecryptionFailure, EncryptedStreamImage?>>((
        asset,
      ) async {
        try {
          // Ottieni il file dall'AssetEntity
          final file = await asset.file;
          if (file == null) return Right(null);
          if (file.path.endsWith(Constants.noImageName)) return Right(null);

          final bytes = await file.readAsBytes();

          final encryptedImage = EncryptedImage(
            path: file.path,
            date: asset.createDateTime,
            encryptedInfo: BytesInfo(
              bytes: bytes,
              hash: ByteModeling.generateHash(bytes),
            ),
            isPrivateFolder: false,
          );

          // Crea un EncryptedStreamImage dall'asset pubblico
          final publicImage = EncryptedStreamImage.image(
            image: encryptedImage,
            type: EncryptedStreamImageType.newImage,
          );
          return Right(publicImage);
        } catch (e) {
          appLogger.logUsecase(
            'Error reading public image ${asset.id}',
            error: e.toString(),
          );
          return Left(DecryptionFailure.decryptionError(e.toString()));
        }
      });

      await for (final result in fileStream) {
        if (result.isLeft()) continue;
        if (result.right == null) continue;

        yield Right(result.right!);
      }
    } catch (e) {
      appLogger.logUsecase('Error reading public gallery', error: e.toString());
      yield Left(DecryptionFailure.decryptionError(e.toString()));
    }
  }
}
