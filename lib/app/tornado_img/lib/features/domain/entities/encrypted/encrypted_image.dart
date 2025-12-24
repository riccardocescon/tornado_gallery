import 'dart:typed_data';

import 'package:tornado_img_app/features/domain/entities/app_image.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';

class EncryptedImage extends AppImage with EncryptedEntity {
  Uint8List? decryptedBytes;
  bool isDecrypting = false;

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
