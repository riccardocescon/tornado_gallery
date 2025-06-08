import 'package:tornado_img/models/app_image.dart';

class EncryptedImage extends AppImage {
  const EncryptedImage({required super.file, required super.date});

  @override
  String toString() {
    return 'EncryptedImage(file: ${file.path}, date: $date)';
  }
}
