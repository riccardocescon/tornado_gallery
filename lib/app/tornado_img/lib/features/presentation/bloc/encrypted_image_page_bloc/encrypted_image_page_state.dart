part of 'encrypted_image_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedImagePageState
    with _$EncryptedImagePageState, EquatableMixin {
  const EncryptedImagePageState._();

  const factory EncryptedImagePageState.initial() = _Initial;
  const factory EncryptedImagePageState.loading() = _Loading;
  const factory EncryptedImagePageState.ui({required EncryptedImage image}) =
      _Ui;
  const factory EncryptedImagePageState.imageSaved({required String path}) =
      _ImageSaved;
  const factory EncryptedImagePageState.imageRenamed() = _ImageRenamed;
  const factory EncryptedImagePageState.failure({required String message}) =
      _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    ui: (value) => [value.image],
    imageSaved: (s) => [s.path],
    imageRenamed: (_) => [],
    failure: (value) => [value.message],
  );
}
