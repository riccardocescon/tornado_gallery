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

  const factory EncryptionPageEvent.toggleGalleryVisibility() =
      _ToggleGalleryVisibility;

  const factory EncryptionPageEvent.setOutputFolder({
    required String outputFolder,
  }) = _SetOutputFolder;

  const factory EncryptionPageEvent.toggleOverrideImage() =
      _ToggleOverrideImage;
      
  const factory EncryptionPageEvent.toggleDeleteOriginals() =
      _ToggleDeleteOriginals;

  const factory EncryptionPageEvent.encrypt() = _Encrypt;
}
