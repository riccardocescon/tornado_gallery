import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

EncryptedImage _img(String path, {bool isPrivate = true}) => EncryptedImage(
  storagePath: StoragePath(
    path: path,
    isPrivateFolder: isPrivate,
    assetId: null,
  ),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

void main() {
  group('EncryptedFolder.copyWith', () {
    test(
      'preserves subfolders when only images are overridden (regression)',
      () {
        final child = EncryptedFolder.empty('/enc/Vacanze', true);
        final folder = EncryptedFolder(
          path: '/enc',
          images: [],
          subfolders: [child],
          isPrivateFolder: true,
        );

        final updated = folder.copyWith(images: [_img('/enc/a.png')]);

        expect(updated.images, hasLength(1));
        expect(updated.subfolders, equals([child]));
      },
    );

    test('overrides subfolders when provided', () {
      final folder = EncryptedFolder.empty('/enc', true);
      final newChild = EncryptedFolder.empty('/enc/New', true);

      final updated = folder.copyWith(subfolders: [newChild]);

      expect(updated.subfolders, equals([newChild]));
    });
  });

  group('EncryptedFolder.storeRelativePath', () {
    test('private folder is relative to encrypted/', () {
      final folder = EncryptedFolder.empty('/app/encrypted/Vacanze/Mare', true);
      expect(folder.storeRelativePath, 'Vacanze/Mare');
    });

    test('gallery folder is relative to TornadoGallery', () {
      final folder = EncryptedFolder.empty('TornadoGallery/Vacanze', false);
      expect(folder.storeRelativePath, 'Vacanze');
    });

    test('root returns empty', () {
      final folder = EncryptedFolder.empty('/app/encrypted', true);
      expect(folder.storeRelativePath, '');
    });
  });

  group('EncryptedImage.storeRelativeDir', () {
    test('private image directory relative to encrypted/', () {
      expect(
        _img('/app/encrypted/Vacanze/Mare/b.png').storeRelativeDir,
        'Vacanze/Mare',
      );
    });

    test('private image at root returns empty', () {
      expect(_img('/app/encrypted/a.png').storeRelativeDir, '');
    });

    test('gallery image directory relative to TornadoGallery', () {
      expect(
        _img(
          '/sdcard/Pictures/TornadoGallery/Vacanze/a.png',
          isPrivate: false,
        ).storeRelativeDir,
        'Vacanze',
      );
    });
  });
}
