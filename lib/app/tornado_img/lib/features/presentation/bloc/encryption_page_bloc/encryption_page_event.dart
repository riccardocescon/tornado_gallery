part of 'encryption_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptionPageEvent with _$EncryptionPageEvent {
  const EncryptionPageEvent._();

  const factory EncryptionPageEvent.setup({
    required List<GalleryImage> images,
  }) = _Setup;

  const factory EncryptionPageEvent.setPassword({required String password}) =
      _SetPassword;
      
  const factory EncryptionPageEvent.setFileName({required String name}) =
      _SetFileName;

  const factory EncryptionPageEvent.selectImage({required int index}) =
      _SelectImage;

  const factory EncryptionPageEvent.toggleGalleryVisibility() =
      _ToggleGalleryVisibility;

  /// Selects a private (encrypted store) destination folder. [relative] is the
  /// folder path under the encrypted root ('' = root); [label] is shown in the
  /// UI. Mirrors [setPublicAlbum] so the private store is relative-based too.
  const factory EncryptionPageEvent.setOutputFolder({
    required String relative,
    required String label,
  }) = _SetOutputFolder;

  /// Selects a public (gallery) destination folder. [relative] is the album
  /// path under the public root ('' = root); [label] is shown in the UI.
  const factory EncryptionPageEvent.setPublicAlbum({
    required String relative,
    required String label,
  }) = _SetPublicAlbum;

  const factory EncryptionPageEvent.toggleOverrideImage() =
      _ToggleOverrideImage;
      
  const factory EncryptionPageEvent.toggleDeleteOriginals() =
      _ToggleDeleteOriginals;

  const factory EncryptionPageEvent.encrypt() = _Encrypt;
}
