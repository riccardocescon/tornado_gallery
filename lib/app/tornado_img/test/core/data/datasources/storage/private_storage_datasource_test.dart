import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/datasources/storage/private_storage_datasource.dart';

void main() {
  late Directory tmp;
  late PrivateStorageDatasource datasource;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('private_storage_datasource_test');
    datasource = PrivateStorageDatasource();
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  group('PrivateStorageDatasource.readAllImages', () {
    test('includes encrypted video files alongside images', () async {
      final photo = File('${tmp.path}${Platform.pathSeparator}photo.png');
      final clip = File('${tmp.path}${Platform.pathSeparator}clip.mp4');
      await photo.writeAsBytes([1, 2, 3]);
      await clip.writeAsBytes([4, 5, 6]);

      final images = await datasource.readAllImages(tmp).toList();
      final names = images.map((e) => e.storagePath.path).toList();

      expect(names, contains(photo.path));
      expect(names, contains(clip.path));
      expect(images.length, 2);
    });

    test('still skips unsupported extensions', () async {
      await File(
        '${tmp.path}${Platform.pathSeparator}notes.txt',
      ).writeAsBytes([1]);

      final images = await datasource.readAllImages(tmp).toList();

      expect(images, isEmpty);
    });
  });
}
