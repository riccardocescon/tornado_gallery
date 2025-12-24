part of 'encrypted_gallery_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedGalleryEvent
    with _$EncryptedGalleryEvent, EquatableMixin {
  const EncryptedGalleryEvent._();
  
  const factory EncryptedGalleryEvent.decrytImage({
    required EncryptedImage image,
    required String password,
    required String? path,
  }) = _DecryptImage;
  
  const factory EncryptedGalleryEvent.decrytFolder({
    required List<EncryptedImage> images,
    required String password,
  }) = _DecryptFolder;

  @override
  List<Object?> get props => [];
}
