part of 'encrypted_image_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedImagePageEvent
    with _$EncryptedImagePageEvent, EquatableMixin {
  const EncryptedImagePageEvent._();

  const factory EncryptedImagePageEvent.setup({required String imagePath}) =
      _Setup;

  @override
  List<Object?> get props => [];
}
