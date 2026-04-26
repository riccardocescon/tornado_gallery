import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

enum EncryptedStreamImageType { newImage, updatedImage, deletedImage }

class EncryptedStreamImage {
  final String? path;
  final EncryptedImage? image;
  final EncryptedStreamImageType type;

  const EncryptedStreamImage._({
    required this.path,
    required this.image,
    required this.type,
  });

  factory EncryptedStreamImage.image({
    required EncryptedImage image,
    required EncryptedStreamImageType type,
  }) {
    return EncryptedStreamImage._(image: image, path: null, type: type);
  }

  factory EncryptedStreamImage.path({
    required String path,
    required EncryptedStreamImageType type,
  }) {
    return EncryptedStreamImage._(image: null, path: path, type: type);
  }
}
