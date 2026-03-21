part of 'encrypted_gallery_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedGalleryEvent
    with _$EncryptedGalleryEvent, EquatableMixin {
  const EncryptedGalleryEvent._();
  
  const factory EncryptedGalleryEvent.decryptImage({
    required EncryptedImage image,
    required String password,
  }) = _DecryptImage;

  const factory EncryptedGalleryEvent.decryptFolder({
    required List<EncryptedImage> images,
    required String password,
  }) = _DecryptFolder;

  const factory EncryptedGalleryEvent.deleteFolderGlobal({
    required String folderName,
  }) = _DeleteFolderGlobal;

  @override
  List<Object?> get props => [];
}
