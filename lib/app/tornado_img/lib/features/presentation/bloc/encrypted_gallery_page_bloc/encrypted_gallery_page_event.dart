part of 'encrypted_gallery_page_bloc.dart';

@Freezed(equal: false)
abstract class EncrpytedGalleryPageEvent
    with _$EncrpytedGalleryPageEvent, EquatableMixin {
  const EncrpytedGalleryPageEvent._();

  const factory EncrpytedGalleryPageEvent.setup({
    required String? currentRoute,
  }) = _Setup;
  const factory EncrpytedGalleryPageEvent.pickFiles() = _PickFiles;
  const factory EncrpytedGalleryPageEvent.decryptImage({
    required EncryptedImage image,
    required String password,
    required String? path,
  }) = _DecryptImage;
  const factory EncrpytedGalleryPageEvent.decryptFolder({
    required String password,
  }) = _DecryptFolder;
  const factory EncrpytedGalleryPageEvent.deleteFolder({
    required String folderName,
  }) = _DeleteFolder;
  const factory EncrpytedGalleryPageEvent.createFolder({
    required String folderName,
  }) = _CreateFolder;
  const factory EncrpytedGalleryPageEvent.loadNextPage() = _LoadNextPage;
  const factory EncrpytedGalleryPageEvent.deleteImage({
    required EncryptedImage image,
  }) = _DeleteImage;

  @override
  List<Object?> get props => [];
}
