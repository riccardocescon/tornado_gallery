part of 'encrypted_image_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedImagePageEvent
    with _$EncryptedImagePageEvent {
  const EncryptedImagePageEvent._();

  const factory EncryptedImagePageEvent.setup({required String imagePath}) =
      _Setup;

  const factory EncryptedImagePageEvent.updatePassword(String password) =
      _UpdatePassword;

  const factory EncryptedImagePageEvent.decrypt() = _Decrypt;

  const factory EncryptedImagePageEvent.restore() = _Restore;
}
