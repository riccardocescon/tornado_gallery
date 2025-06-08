import 'dart:typed_data';

import 'package:tornado_img/features/models/app_image.dart';

class EncryptedImage extends AppImage {
  Uint8List? decryptedBytes;

  EncryptedImage({
    required super.id,
    required super.file,
    required super.date,
    this.decryptedBytes,
  });

  @override
  String toString() {
    return 'EncryptedImage(file: ${file.path}, date: $date)';
  }
}
