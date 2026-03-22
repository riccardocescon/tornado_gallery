import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/repositories/storage_repository_impl.dart';

// ---------------------------------------------------------------------------
// Testable subclass — overrides base dir so we never call
// getApplicationDocumentsDirectory() (a platform channel).
// ---------------------------------------------------------------------------
class _TestableStorageRepo extends StorageRepositoryImpl {
  final String baseDirectory;
  _TestableStorageRepo(this.baseDirectory);

  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    String? path,
  }) {
    // Redirect null path to the provided baseDirectory
    return super.save(
      bytes: bytes,
      fileName: fileName,
      path: path ?? baseDirectory,
    );
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('storage_repo_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  // -------------------------------------------------------------------------
  // save — with explicit path
  // -------------------------------------------------------------------------
  group('StorageRepositoryImpl.save (path)', () {
    final repo = StorageRepositoryImpl();

    test('creates the file at path/encrypted/<fileName>', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      await repo.save(
        bytes: bytes,
        fileName: 'photo.png',
        path: tempDir.path,
      );

      final file = File('${tempDir.path}/encrypted/photo.png');
      expect(await file.exists(), isTrue);
    });

    test('writes the exact bytes to the file', () async {
      final bytes = Uint8List.fromList([10, 20, 30, 40]);

      await repo.save(
        bytes: bytes,
        fileName: 'img.png',
        path: tempDir.path,
      );

      final saved =
          await File('${tempDir.path}/encrypted/img.png').readAsBytes();
      expect(saved, bytes);
    });

    test('creates nested encrypted/ directory if it does not exist', () async {
      final subDir = Directory('${tempDir.path}/new_dir');
      // Do not create subDir — save must create it recursively.

      await repo.save(
        bytes: Uint8List.fromList([7, 8, 9]),
        fileName: 'new.png',
        path: subDir.path,
      );

      expect(await File('${subDir.path}/encrypted/new.png').exists(), isTrue);
    });

    test('overwrites an existing file with new bytes', () async {
      final file = File('${tempDir.path}/encrypted/overwrite.png');
      await file.create(recursive: true);
      await file.writeAsBytes([99, 98, 97]);

      final newBytes = Uint8List.fromList([1, 2, 3]);
      await repo.save(
        bytes: newBytes,
        fileName: 'overwrite.png',
        path: tempDir.path,
      );

      final saved = await file.readAsBytes();
      expect(saved, newBytes);
    });

    test(
      'preserves file content for different file names independently',
      () async {
        final bytes1 = Uint8List.fromList([1, 1, 1]);
        final bytes2 = Uint8List.fromList([2, 2, 2]);

        await repo.save(
          bytes: bytes1,
          fileName: 'a.png',
          path: tempDir.path,
        );
        await repo.save(
          bytes: bytes2,
          fileName: 'b.png',
          path: tempDir.path,
        );

        final savedA =
            await File('${tempDir.path}/encrypted/a.png').readAsBytes();
        final savedB =
            await File('${tempDir.path}/encrypted/b.png').readAsBytes();

        expect(savedA, bytes1);
        expect(savedB, bytes2);
      },
    );
  });

  // -------------------------------------------------------------------------
  // save — null path (redirected via testable subclass)
  // -------------------------------------------------------------------------
  group(
    'StorageRepositoryImpl.save (null path via testable subclass)',
    () {
      test(
        'creates file in the base directory when no path given',
        () async {
          final repo = _TestableStorageRepo(tempDir.path);
          final bytes = Uint8List.fromList([5, 6, 7]);

          await repo.save(bytes: bytes, fileName: 'default.png');

          final file = File('${tempDir.path}/encrypted/default.png');
          expect(await file.exists(), isTrue);
          expect(await file.readAsBytes(), bytes);
        },
      );
    },
  );
}
