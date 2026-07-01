import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';

class GalleryReaderUseCase extends StreamUseCase<EncryptedStreamImage, void> {
  final ImageProcessingRepository imageRepo;
  final StorageRepository storageRepo;

  GalleryReaderUseCase({required this.imageRepo, required this.storageRepo});

  Stream<String> readPrivateFolderPaths() async* {
    final path = await GalleryPathProvider.getPrivateFolderPath();
    yield* storageRepo.readPrivateFolderPaths(path);
  }

  Stream<String> readPublicFolderPaths() => storageRepo.readPublicFolderPaths();

  @override
  Stream<Either<DecryptionFailure, EncryptedStreamImage>> call(
    void params,
  ) async* {
    try {
      final privateFolderPath =
          await GalleryPathProvider.getPrivateFolderPath();
      yield* storageRepo
          .readPrivateImages(privateFolderPath)
          .asyncMap((image) => Right(image));

      yield* storageRepo.readPublicGalleryImages().asyncMap(
        (image) => Right(image),
      );
    } catch (e) {
      appLogger.log(
        'Error reading gallery',
        LogLayer.usecase,
        error: e.toString(),
      );
      yield Left(DecryptionFailure.decryptionError(e.toString()));
    }
  }
}
