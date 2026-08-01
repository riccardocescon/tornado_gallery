import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

/// Copies a video file into the public gallery album.
///
/// The bytes-based [ImageSaverUseCase] cannot be reused here: the file may be
/// gigabytes, so it is handed to the platform by path.
class VideoSaverUseCase extends EncryptionUseCase<void, VideoSaverParams> {
  final StorageRepository storageRepo;

  VideoSaverUseCase({required this.storageRepo});

  @override
  Future<Either<EncryptionFailure, void>> call(VideoSaverParams params) {
    return guardEither('Error saving video', () async {
      await storageRepo.saveVideo(
        filePath: params.filePath,
        album: params.album ?? Constants.appFolderName,
      );
      return const Right(null);
    });
  }
}

class VideoSaverParams {
  final String filePath;
  final String? album;

  VideoSaverParams({required this.filePath, this.album});
}
