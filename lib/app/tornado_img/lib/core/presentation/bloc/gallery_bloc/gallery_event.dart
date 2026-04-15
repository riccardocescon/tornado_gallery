part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryEvent with _$GalleryEvent, EquatableMixin {
  const GalleryEvent._();

  const factory GalleryEvent.encryptImages({
    required List<GalleryImage> images,
    required String password,
    required EncryptionSettings settings,
  }) = _EncryptImages;

  const factory GalleryEvent.decryptImage({
    required EncryptedImage image,
    required String password,
  }) = _DecryptImage;

  @override
  List<Object?> get props => when(
    encryptImages: (images, password, path) => [images, password, path],
    decryptImage: (image, password) => [image, password],
  );
}
