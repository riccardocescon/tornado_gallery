part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryEvent with _$GalleryEvent, EquatableMixin {
  const GalleryEvent._();

  const factory GalleryEvent.setup() = _Setup;
  const factory GalleryEvent.loadNextPage() = _LoadNextPage;
  const factory GalleryEvent.pickFiles() = _PickFiles;
  const factory GalleryEvent.deleteImage({required GalleryImage image}) =
      _DeleteImage;
  const factory GalleryEvent.encryptImage({
    required GalleryImage image,
    required String password,
    required String? path,
  }) = _EncryptImage;

  @override
  List<Object?> get props => [];
}
