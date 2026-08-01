import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/datasources/storage/private_storage_datasource.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';

void main() {
  late Directory tmp;
  late PrivateStorageDatasource datasource;
  final tPoster = Uint8List.fromList(List.generate(32, (i) => i & 0xFF));

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
      await clip.writeAsBytes([...buildPosterBox(tPoster), 9, 9, 9]);

      final images = await datasource.readAllImages(tmp).toList();
      final names = images.map((e) => e.storagePath.path).toList();

      expect(names, contains(photo.path));
      expect(names, contains(clip.path));
      expect(images.length, 2);
    });

    test('carries the poster, not the whole video, as preview bytes', () async {
      // The point of the poster box: a scan must never pull a multi-GB
      // ciphertext into memory just to show a thumbnail.
      final clip = File('${tmp.path}${Platform.pathSeparator}clip.mp4');
      final ciphertext = List.filled(4096, 0x5A);
      await clip.writeAsBytes([...buildPosterBox(tPoster), ...ciphertext]);

      final images = await datasource.readAllImages(tmp).toList();

      expect(images.single.encryptedInfo.bytes, equals(tPoster));
    });

    test('skips an mp4 that carries no poster box', () async {
      // Not one of ours (or corrupt) — reading it whole is exactly what the
      // poster box exists to avoid.
      await File(
        '${tmp.path}${Platform.pathSeparator}foreign.mp4',
      ).writeAsBytes([4, 5, 6]);

      expect(await datasource.readAllImages(tmp).toList(), isEmpty);
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
