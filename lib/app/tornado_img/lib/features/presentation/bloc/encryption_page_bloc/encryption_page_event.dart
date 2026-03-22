part of 'encryption_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptionPageEvent with _$EncryptionPageEvent {
  const EncryptionPageEvent._();

  const factory EncryptionPageEvent.setup({
    required List<GalleryImage> images,
  }) = _Setup;

  const factory EncryptionPageEvent.setPassword({required String password}) =
      _SetPassword;

  const factory EncryptionPageEvent.toggleGalleryVisibility() =
      _ToggleGalleryVisibility;

  const factory EncryptionPageEvent.setOutputFolder({
    required String outputFolder,
  }) = _SetOutputFolder;

  const factory EncryptionPageEvent.toggleDeleteOriginals() =
      _ToggleDeleteOriginals;

  const factory EncryptionPageEvent.encrypt() = _Encrypt;
}
