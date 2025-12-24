part of 'gallery_page_bloc.dart';

@Freezed(equal: false)
abstract class GalleryPageEvent with _$GalleryPageEvent, EquatableMixin {
  const GalleryPageEvent._();

  const factory GalleryPageEvent.setup() = _Setup;
  const factory GalleryPageEvent.pickFiles() = _PickFiles;
  const factory GalleryPageEvent.encryptImage({
    required GalleryImage image,
    required String password,
    required String? path,
  }) = _EncryptImage;
  const factory GalleryPageEvent.loadNextPage() = _LoadNextPage;
  const factory GalleryPageEvent.deleteImage({required GalleryImage image}) =
      _DeleteImage;
  const factory GalleryPageEvent.saveScrollPosition({
    required double position,
  }) = _SaveScrollPosition;

  @override
  List<Object?> get props => [];
}
