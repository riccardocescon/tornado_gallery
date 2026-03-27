import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

enum GalleryStreamImageType { newImage, updatedImage, deletedImage }

class GalleryStreamImage {
  final String? path;
  final GalleryImage? image;
  final GalleryStreamImageType type;

  const GalleryStreamImage._({
    required this.path,
    required this.image,
    required this.type,
  });

  factory GalleryStreamImage.image({
    required GalleryImage image,
    required GalleryStreamImageType type,
  }) {
    return GalleryStreamImage._(image: image, path: null, type: type);
  }

  factory GalleryStreamImage.path({
    required String path,
    required GalleryStreamImageType type,
  }) {
    return GalleryStreamImage._(image: null, path: path, type: type);
  }
}
