import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

class EncryptedFolder with EncryptedEntity {
  final String path;
  final List<EncryptedImage> images;
  final List<EncryptedFolder> subfolders;
  final bool isPrivateFolder;

  String get name => path.split('/').last;
  String get encryptedRelativePath {
    final parts = path.split('/');
    final relatives = parts.skipWhile((part) => part != 'encrypted').skip(1);
    final fullPath = relatives.join('/');
    return Uri.encodeComponent(fullPath);
  }

  EncryptedFolder({
    required this.images,
    required this.path,
    List<EncryptedFolder>? subfolders,
    required this.isPrivateFolder,
  }) : subfolders = subfolders ?? [];

  @override
  EncryptedFolder copyWith({List<EncryptedImage>? images}) {
    return EncryptedFolder(
      images: images ?? this.images,
      path: path,
      subfolders: subfolders,
      isPrivateFolder: isPrivateFolder,
    );
  }

  factory EncryptedFolder.empty(String path, bool isPrivateFolder) {
    return EncryptedFolder(
      images: [],
      path: path,
      isPrivateFolder: isPrivateFolder,
    );
  }
}
