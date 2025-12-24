part of 'encrypted_gallery_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedGalleryEvent
    with _$EncryptedGalleryEvent, EquatableMixin {
  const EncryptedGalleryEvent._();

  const factory EncryptedGalleryEvent.setup() = _Setup;
  const factory EncryptedGalleryEvent.loadNextPage() = _LoadNextPage;
  const factory EncryptedGalleryEvent.deleteImage({
    required EncryptedImage image,
  }) = _DeleteImage;
  const factory EncryptedGalleryEvent.decrytImage({
    required EncryptedImage image,
    required String password,
    required String? path,
  }) = _DecryptImage;
  const factory EncryptedGalleryEvent.decrytFolder({
    required EncryptedImage image,
    required String password,
    required String? path,
  }) = _DecryptFolder;
  const factory EncryptedGalleryEvent.createFolder({
    required String folderName,
  }) = _CreateFolder;
  const factory EncryptedGalleryEvent.deleteFolder() = _DeleteFolder;

  @override
  List<Object?> get props => [];
}
