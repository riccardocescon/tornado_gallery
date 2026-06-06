import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

typedef AppFolderState =
    (EncryptedFolder privateFolder, EncryptedFolder? publicFolder);

class AppFolderStreamerUsecase {
  final AppRepository appRepository;

  StreamManager? _streamManager;

  AppFolderStreamerUsecase({required this.appRepository});

  Stream<AppFolderState> call() async* {
    try {
      final privateFolder = await appRepository.loadPrivateRootFolder();
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

  EncryptedFolder? mergeArchivedPublicImages({
    required EncryptedFolder? currentPublicFolder,
    required List<EncryptedImage> archivedImages,
  }) {
    final publicImages = archivedImages
        .where((img) => !img.storagePath.isPrivateFolder)
        .toList();
    if (publicImages.isEmpty) return currentPublicFolder;

    final root =
        currentPublicFolder ??
        EncryptedFolder.empty(_inferPublicRootPath(publicImages.first), false);

    final mergedByPath = <String, EncryptedImage>{
      for (final img in root.images) img.storagePath.path: img,
    };
    for (final img in publicImages) {
      mergedByPath[img.storagePath.path] = img;
    }

    final mergedImages = mergedByPath.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return root.copyWith(images: mergedImages);
  }

  String _inferPublicRootPath(EncryptedImage image) {
    final path = image.storagePath.path;
    if (path.trim().isEmpty) return 'public';
    return Directory(path).parent.path;
  }
}
