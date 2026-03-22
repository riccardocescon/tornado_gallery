import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  FakePathProviderPlatform(this.applicationDocumentsPath);

  final String applicationDocumentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return applicationDocumentsPath;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory encryptedDir;
  late HomepageBlocUtils utils;
  late PathProviderPlatform originalPlatform;

  String safePath(String path) => path.replaceAll("\\", "/");

  setUp(() async {
    originalPlatform = PathProviderPlatform.instance;

    tempDir = await Directory.systemTemp.createTemp(
      'homepage_bloc_utils_watch_test_',
    );

    encryptedDir = Directory('${tempDir.path}/encrypted');
    await encryptedDir.create(recursive: true);

    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
    utils = HomepageBlocUtils();
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('watchAppFolderChanges', () {
    test(
      'adds a new folder to rootFolder when created and yields after insertion',
      () async {
        final rootFolder = await utils.loadAppRootFolder();

        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = utils.watchAppFolderChanges(rootFolder).listen((_) {
          completer.complete();
        });

        await Future<void>.delayed(const Duration(milliseconds: 100));

        final newFolderPath = '${encryptedDir.path}/album_1';
        await Directory(newFolderPath).create(recursive: true);

        await completer.future.timeout(const Duration(seconds: 3));

        expect(
          rootFolder.subfolders.any(
            (folder) => safePath(folder.path) == safePath(newFolderPath),
          ),
          isTrue,
        );

        sub.cancel();
      },
    );

    test(
      'removes a folder from rootFolder when deleted and yields after removal',
      () async {
        final folderToDelete = Directory(
          '${encryptedDir.path}/album_to_delete',
        );
        await folderToDelete.create(recursive: true);

        final rootFolder = await utils.loadAppRootFolder();
        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = utils.watchAppFolderChanges(rootFolder).listen((_) {
          completer.complete();
        });

        expect(
          rootFolder.subfolders.any(
            (folder) => safePath(folder.path) == safePath(folderToDelete.path),
          ),
          isTrue,
        );

        await Future.delayed(const Duration(seconds: 3));

        await folderToDelete.delete(recursive: true);

        await completer.future.timeout(const Duration(seconds: 10));

        expect(
          rootFolder.subfolders.any(
            (folder) => safePath(folder.path) == safePath(folderToDelete.path),
          ),
          isFalse,
        );

        await sub.cancel();
      },
    );

    test(
      'adds an image to the parent folder when created and yields after insertion',
      () async {
        final albumDir = Directory('${encryptedDir.path}/album_images');
        await albumDir.create(recursive: true);

        final rootFolder = await utils.loadAppRootFolder();
        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = utils.watchAppFolderChanges(rootFolder).listen((_) {
          completer.complete();
        });

        final parentFolder = rootFolder.subfolders.firstWhere(
          (folder) => safePath(folder.path) == safePath(albumDir.path),
        );

        expect(parentFolder.images, isEmpty);

        await Future.delayed(const Duration(seconds: 3));

        final imagePath = '${albumDir.path}/photo_1.jpg';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes([1, 2, 3, 4]);

        await completer.future.timeout(const Duration(seconds: 10));

        expect(parentFolder.images.length, 1);
        expect(parentFolder.images.first.name, 'photo_1.jpg');
        expect(
          safePath(parentFolder.images.first.file.path),
          safePath(imagePath),
        );

        sub.cancel();
      },
    );

    test(
      'removes an image from the parent folder when deleted and yields after removal',
      () async {
        final albumDir = Directory('${encryptedDir.path}/album_delete_image');
        await albumDir.create(recursive: true);

        final imagePath = '${albumDir.path}/photo_to_delete.jpg';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes([1, 2, 3, 4]);

        final rootFolder = await utils.loadAppRootFolder();
        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = utils.watchAppFolderChanges(rootFolder).listen((_) {
          completer.complete();
        });

        final parentFolder = rootFolder.subfolders.firstWhere(
          (folder) => safePath(folder.path) == safePath(albumDir.path),
        );

        expect(
          parentFolder.images.any((img) => img.name == 'photo_to_delete.jpg'),
          isTrue,
        );

        await Future.delayed(const Duration(seconds: 3));

        await imageFile.delete();

        await completer.future.timeout(const Duration(seconds: 3));

        expect(
          parentFolder.images.any((img) => img.name == 'photo_to_delete.jpg'),
          isFalse,
        );

        sub.cancel();
      },
    );
  });
}
