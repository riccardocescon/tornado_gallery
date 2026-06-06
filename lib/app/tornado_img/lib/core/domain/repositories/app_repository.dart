import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

abstract class AppRepository {
  Future<EncryptedFolder> loadPrivateRootFolder();

  Future<EncryptedFolder?> loadPublicRootFolder();

  Stream<void> watchFolderChanges(EncryptedFolder rootFolder);

  Future<bool> createPublicFolder();

  Future<List<GalleryImage>> mapAssetsToGalleryImages(List<AssetEntity> assets);

  Future<void> dispose();
}
