import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

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

  /// Folder path relative to its store root, used to address the folder in
  /// repository/usecase calls. Private store is rooted at `encrypted/`,
  /// the gallery at the `TornadoGallery` root album. Returns '' for the root.
  String get storeRelativePath {
    final marker = isPrivateFolder ? 'encrypted' : Constants.appFolderName;
    final parts = path.replaceAll('\\', '/').split('/');
    final idx = parts.lastIndexOf(marker);
    if (idx == -1) return '';
    return parts.skip(idx + 1).where((p) => p.trim().isNotEmpty).join('/');
  }

  EncryptedFolder({
    required this.images,
    required this.path,
    List<EncryptedFolder>? subfolders,
    required this.isPrivateFolder,
  }) : subfolders = subfolders ?? [];

  @override
  EncryptedFolder copyWith({
    List<EncryptedImage>? images,
    List<EncryptedFolder>? subfolders,
  }) {
    return EncryptedFolder(
      images: images ?? this.images,
      path: path,
      subfolders: subfolders ?? this.subfolders,
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
