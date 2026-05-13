import 'package:rxdart/rxdart.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';

typedef AppFolderState =
    (EncryptedFolder privateFolder, EncryptedFolder? publicFolder);

class AppFolderStreamerUsecase {
  final AppRepository appRepository;

  StreamManager? _streamManager;

  AppFolderStreamerUsecase({required this.appRepository});

  Stream<AppFolderState> call() async* {
    try {
      final privateFolder = await appRepository.loadRootFolder();
      EncryptedFolder? publicFolder =
          await appRepository.loadPublicRootFolder();

      if (publicFolder == null) {
        final success = await appRepository.createPublicFolder();
        if (success) {
          publicFolder = await appRepository.loadPublicRootFolder();
        }
      }

      yield (privateFolder, publicFolder);

      final privateStream = appRepository.watchFolderChanges(privateFolder);
      final Stream? publicStream =
          publicFolder != null
              ? appRepository.watchFolderChanges(publicFolder)
              : null;

      final merged = Rx.merge([
        privateStream,
        if (publicStream != null) publicStream,
      ]);
      _streamManager = StreamManager.fromStream(merged);

      await for (final _ in _streamManager!.stream
          .debounceTime(const Duration(milliseconds: 200))) {
        yield (privateFolder, publicFolder);
      }
    } catch (e) {
      appLogger.logUsecase('Error streaming app folders', error: e.toString());
    }
  }

  Future<void> dispose() async {
    await _streamManager?.dispose();
  }
}
