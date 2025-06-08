import 'package:tornado_img/models/app_image.dart';

class GalleryImage extends AppImage {
  const GalleryImage({required super.file, required super.date});

  @override
  String toString() {
    return 'GalleryImage(file: ${file.path}, date: $date)';
  }
}
