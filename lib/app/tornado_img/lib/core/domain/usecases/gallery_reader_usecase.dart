import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
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
      final privateFolderPath = await GalleryPathProvider.getOutputFolderRoot(
        galleryVisible: false,
      );
      yield* storageRepo
          .readImages(privateFolderPath!)
          .asyncMap((image) => Right(image));

      // TODO: stream for public folder
    } catch (e) {
      appLogger.logUsecase('Error reading gallery', error: e.toString());
      yield Left(DecryptionFailure.decryptionError(e.toString()));
    }
  }
}
