part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryEvent with _$GalleryEvent, EquatableMixin {
  const GalleryEvent._();

  const factory GalleryEvent.encryptImage({
    required GalleryImage image,
    required String password,
    required String? path,
  }) = _EncryptImage;

  @override
  List<Object?> get props => [image, password, path];
}
