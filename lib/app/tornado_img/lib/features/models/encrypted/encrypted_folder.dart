import 'package:tornado_img_app/features/models/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/models/encrypted/encrypted_image.dart';

class EncryptedFolder extends EncryptedEntity {
  final String path;
  final List<EncryptedImage> images;

  String get name => path.split('/').last;
  String get encryptedRelativePath {
    final parts = path.split('/');
    final relatives = parts.skipWhile((part) => part != 'encrypted').skip(1);
    final fullPath = relatives.join('/');
    return Uri.encodeComponent(fullPath);
  }

  EncryptedFolder({required this.images, required this.path});

  factory EncryptedFolder.empty(String path) {
    return EncryptedFolder(images: [], path: path);
  }
}
