import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

abstract interface class Encryptable {
  Encryptable copyWith();
}

mixin EncryptedEntity implements Encryptable {
  bool get isImage => this is EncryptedImage;
  EncryptedImage get asImage => this as EncryptedImage;
  EncryptedImage? get tryImage => isImage ? asImage : null;

  bool get isFolder => this is EncryptedFolder;
  EncryptedFolder get asFolder => this as EncryptedFolder;
  EncryptedFolder? get tryFolder => isFolder ? asFolder : null;
  
}
