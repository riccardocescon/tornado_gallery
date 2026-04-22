part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryEvent with _$GalleryEvent, EquatableMixin {
  const GalleryEvent._();

  const factory GalleryEvent.encryptImages({
    required List<GalleryImage> images,
    required String password,
    required EncryptionSettings settings,
    required String? filename,
  }) = _EncryptImages;

  const factory GalleryEvent.decryptImages({
    required List<EncryptedImage> image,
    required String password,
  }) = _DecryptImages;

  @override
  List<Object?> get props => when(
    encryptImages:
        (images, password, settings, filename) => [
          images,
          password,
          settings,
          filename,
        ],
    decryptImages: (image, password) => [image, password],
  );
}
