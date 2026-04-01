import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/repositories/encrypted_gallery_repository/encrypted_gallery_repository_impl.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

/// Testable subclass that overrides [getEncryptedFolder] to use [baseDir]
/// instead of the real path_provider, allowing pure I/O tests without
/// platform channels.
class _TestableRepo extends EncryptedGalleryRepositoryImpl {
  final Directory baseDir;
  _TestableRepo(this.baseDir);

  @override
  Future<Directory> getEncryptedFolder() async => baseDir;
}

/// Testable subclass that also intercepts [decryptImage] so that [decryptFolder]
/// can be tested without relying on the native crypto library.
class _TestableRepoWithFakeDecrypt extends _TestableRepo {
  final Either<EncryptionFailure, Uint8List> Function(EncryptedImage)
  decryptResult;

  _TestableRepoWithFakeDecrypt(super.baseDir, {required this.decryptResult});

  @override
  Future<Either<EncryptionFailure, Uint8List>> decryptImage({
    required EncryptedImage image,
    required String password,
  }) async => decryptResult(image);
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('enc_gallery_repo_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // ---------------------------------------------------------------------------
  // getEncryptedFolder (via override)
  // ---------------------------------------------------------------------------
  group('getEncryptedFolder', () {
    test('returns the overridden base directory', () async {
      final repo = _TestableRepo(tempDir);
      final dir = await repo.getEncryptedFolder();
      expect(dir.path, tempDir.path);
    });
  });

  // ---------------------------------------------------------------------------
  // deleteFolder
  // ---------------------------------------------------------------------------
  group('deleteFolder', () {
    test('deletes an existing folder and returns Right(null)', () async {
      final repo = _TestableRepo(tempDir);
      final folder = Directory('${tempDir.path}/summer');
      await folder.create();
      expect(await folder.exists(), isTrue);

      final result = await repo.deleteFolder('summer');

      expect(result.isRight(), isTrue);
      expect(await folder.exists(), isFalse);
    });

    test('returns Right(null) when folder does not exist', () async {
      final repo = _TestableRepo(tempDir);

      final result = await repo.deleteFolder('nonexistent');

      expect(result.isRight(), isTrue);
    });

    test('deletes nested content recursively', () async {
      final repo = _TestableRepo(tempDir);
      final nested = Directory('${tempDir.path}/vacation/photos/raw');
      await nested.create(recursive: true);
      final file = File('${nested.path}/img.png');
      await file.writeAsBytes([1, 2, 3]);

      final result = await repo.deleteFolder('vacation');

      expect(result.isRight(), isTrue);
      expect(await Directory('${tempDir.path}/vacation').exists(), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // decryptFolder (via _TestableRepoWithFakeDecrypt)
  // ---------------------------------------------------------------------------
  group('decryptFolder', () {
    EncryptedImage _img(String id) => EncryptedImage(
      path: '${tempDir.path}/$id.png',
      date: DateTime(2024),
    );

    test('returns Right with all successfully decrypted images', () async {
      final tBytes = Uint8List.fromList([1, 2, 3]);
      final img1 = _img('img1');
      final img2 = _img('img2');

      final repo = _TestableRepoWithFakeDecrypt(
        tempDir,
        decryptResult: (_) => Right(tBytes),
      );

      final result = await repo.decryptFolder(
        images: [img1, img2],
        password: 'pw',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (decrypted) {
        expect(decrypted.length, 2);
        expect(decrypted[0].bytes, tBytes);
        expect(decrypted[1].bytes, tBytes);
      });
    });

    test(
      'skips images that fail to decrypt without returning a Left',
      () async {
        final tBytes = Uint8List.fromList([1, 2, 3]);
        final img1 = _img('img1');
        final img2 = _img('img2');

        int callCount = 0;
        final repo = _TestableRepoWithFakeDecrypt(
          tempDir,
          decryptResult: (img) {
            callCount++;
            if (callCount == 1) {
              return Left(EncryptionFailure.encryptionError('bad'));
            }
            return Right(tBytes);
          },
        );

        final result = await repo.decryptFolder(
          images: [img1, img2],
          password: 'pw',
        );

        // decryptFolder ignores individual failures and returns Right with
        // only the successfully decrypted images.
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (decrypted) => expect(decrypted.length, 1),
        );
      },
    );

    test('returns Right with empty list when all decryptions fail', () async {
      final repo = _TestableRepoWithFakeDecrypt(
        tempDir,
        decryptResult:
            (_) => Left(EncryptionFailure.encryptionError('always fails')),
      );

      final result = await repo.decryptFolder(
        images: [_img('img1')],
        password: 'pw',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (decrypted) => expect(decrypted, isEmpty),
      );
    });

    test('mutates decryptedBytes and isDecrypting on each image', () async {
      final tBytes = Uint8List.fromList([9, 8, 7]);
      final img1 = _img('img1');

      final repo = _TestableRepoWithFakeDecrypt(
        tempDir,
        decryptResult: (_) => Right(tBytes),
      );

      await repo.decryptFolder(images: [img1], password: 'pw');

      expect(img1.bytes, tBytes);
      expect(img1.isDecrypted, true);
    });
  });
}
