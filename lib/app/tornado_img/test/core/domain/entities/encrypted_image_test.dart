import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

EncryptedImage _img(String path) => EncryptedImage(
  storagePath: StoragePath(path: path, isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

void main() {
  group('EncryptedImage.isVideo', () {
    test('is true for a video extension', () {
      expect(_img('/enc/clip.mp4').isVideo, isTrue);
    });

    test('is true regardless of case', () {
      expect(_img('/enc/clip.MOV').isVideo, isTrue);
    });

    test('is false for an image extension', () {
      expect(_img('/enc/photo.png').isVideo, isFalse);
    });
  });

  group('EncryptedImage.name — doubled-extension normalization', () {
    test('strips a doubled image extension', () {
      expect(_img('/enc/188.png.png').name, '188.png');
    });

    test('strips a doubled video extension', () {
      expect(_img('/enc/clip.mp4.mp4').name, 'clip.mp4');
    });

    test('leaves a single video extension untouched', () {
      expect(_img('/enc/clip.mp4').name, 'clip.mp4');
    });
  });
}
