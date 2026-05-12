part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryEvent with _$GalleryEvent, EquatableMixin {
  const GalleryEvent._();

  const factory GalleryEvent.encryptImages({
    required Map<GalleryImage, String?> images,
    required String password,
    required EncryptionSettings settings,
  }) = _EncryptImages;

  const factory GalleryEvent.decryptImages({
    required List<EncryptedImage> image,
    required String password,
  }) = _DecryptImages;

  @override
  List<Object?> get props => when(
    encryptImages: (images, password, settings) => [images, password, settings],
    decryptImages: (image, password) => [image, password],
  );
}
