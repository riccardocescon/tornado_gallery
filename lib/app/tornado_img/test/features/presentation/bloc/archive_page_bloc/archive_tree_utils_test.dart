import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';

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
  final images = [
    _img('/app/encrypted/root.png'),
    _img('/app/encrypted/Vacanze/a.png'),
    _img('/app/encrypted/Vacanze/Mare/b.png'),
    _img('/sdcard/Pictures/TornadoGallery/Gallery1/g.png', isPrivate: false),
  ];

  group('imagesAtLevel', () {
    test('root (null store) returns only store-root images', () {
      final result = ArchiveTreeUtils.imagesAtLevel(
        images,
        isPrivate: null,
        currentPath: '',
      );
      expect(result, hasLength(1));
      expect(result.first.name, 'root.png');
    });

    test('inside a private folder returns its direct images only', () {
      final result = ArchiveTreeUtils.imagesAtLevel(
        images,
        isPrivate: true,
        currentPath: 'Vacanze',
      );
      expect(result.map((i) => i.name), ['a.png']);
    });
  });

  group('foldersAtLevel', () {
    test('root lists top folders from both stores', () {
      final folders = ArchiveTreeUtils.foldersAtLevel(
        images,
        {},
        isPrivate: null,
        currentPath: '',
      );
      expect(
        folders.map((f) => f.name).toSet(),
        {'Vacanze', 'Gallery1'},
      );
    });

    test('recursive image count includes nested images', () {
      final folders = ArchiveTreeUtils.foldersAtLevel(
        images,
        {},
        isPrivate: null,
        currentPath: '',
      );
      final vacanze = folders.firstWhere((f) => f.name == 'Vacanze');
      expect(vacanze.imageCount, 2);
    });

    test('inside Vacanze lists nested folder Mare', () {
      final folders = ArchiveTreeUtils.foldersAtLevel(
        images,
        {},
        isPrivate: true,
        currentPath: 'Vacanze',
      );
      expect(folders.map((f) => f.name), ['Mare']);
    });

    test('created empty folders surface even without images', () {
      final folders = ArchiveTreeUtils.foldersAtLevel(
        [],
        {(isPrivate: true, relativePath: 'Empty')},
        isPrivate: null,
        currentPath: '',
      );
      expect(folders.map((f) => f.name), ['Empty']);
      expect(folders.first.imageCount, 0);
    });
  });

  group('imagesUnder', () {
    test('returns all nested images of a private folder', () {
      final result = ArchiveTreeUtils.imagesUnder(
        images,
        isPrivate: true,
        relativePath: 'Vacanze',
      );
      expect(result.map((i) => i.name).toSet(), {'a.png', 'b.png'});
    });
  });
}
