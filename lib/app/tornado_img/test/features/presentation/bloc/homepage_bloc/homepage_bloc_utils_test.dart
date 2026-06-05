import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tornado_img_app/core/data/repositories/app_repository/app_repository_impl.dart';

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
  late AppRepositoryImpl repo;
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
    repo = AppRepositoryImpl();
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;

    await repo.dispose();

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('watchFolderChanges', () {
    test(
      'adds a new folder to rootFolder when created and yields after insertion',
      () async {
        final rootFolder = await repo.loadPrivateRootFolder();

        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = repo.watchFolderChanges(rootFolder).listen((_) {
          completer.complete();
        });

        // Give the async generator a moment to set up the watcher and reach
        // the `await watcher.ready` checkpoint. On Windows the isolate-based
        // DirectoryWatcher can take up to ~3 s to be ready in flutter test.
        await Future<void>.delayed(const Duration(seconds: 3));

        final newFolderPath = '${encryptedDir.path}/album_1';
        await Directory(newFolderPath).create(recursive: true);
        // DirectoryWatcher does not emit events for empty directory creation.
        // We add a marker file (.nomedia) to trigger an initial ADD event so
        // that _recoverMissingParentFolder scans the new folder, inserts album_1
        // into rootFolder.subfolders and builds the lookup entry. Because the
        // scan immediately finds this file wasPresent=true — no yield yet.
        // After a short delay (scan finishes synchronously, well under 500 ms)
        // we create a second file that is NOT in the cached image list; this
        // second event has wasPresent=false and causes the stream to yield.
        await File('$newFolderPath/.nomedia').writeAsBytes([0]);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await File('$newFolderPath/trigger.jpg').writeAsBytes([1, 2, 3]);

        await completer.future.timeout(const Duration(seconds: 10));

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
      'adds an image to the parent folder when created and yields after insertion',
      () async {
        final albumDir = Directory('${encryptedDir.path}/album_images');
        await albumDir.create(recursive: true);

        final rootFolder = await repo.loadPrivateRootFolder();
        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = repo.watchFolderChanges(rootFolder).listen((_) {
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
          safePath(parentFolder.images.first.storagePath.file.path),
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

        final rootFolder = await repo.loadPrivateRootFolder();
        final completer = Completer<void>();
        late final StreamSubscription sub;

        sub = repo.watchFolderChanges(rootFolder).listen((_) {
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
