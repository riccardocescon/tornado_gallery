part of 'encryption_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptionPageState with _$EncryptionPageState, EquatableMixin {
  const EncryptionPageState._();

  const factory EncryptionPageState.initial() = _Initial;
  const factory EncryptionPageState.loading() = _Loading;
  const factory EncryptionPageState.ui({required List<GalleryImage> images}) =
      _UI;
  const factory EncryptionPageState.settingsUi({
    required bool galleryVisible,
    required String outputFolder,
    required bool deleteOriginals,
  }) = _SettingsUI;
  const factory EncryptionPageState.encrypting() = _Encrypting;
  const factory EncryptionPageState.encrypted() = _Encrypted;
  const factory EncryptionPageState.failure({required String message}) =
      _Failure;

  @override
  List<Object?> get props => when(
    initial: () => [],
    loading: () => [],
    ui: (images) => [images],
    settingsUi:
        (galleryVisible, outputFolder, deleteOriginals) => [
          galleryVisible,
          outputFolder,
          deleteOriginals,
        ],
    encrypting: () => [],
    encrypted: () => [],
    failure: (message) => [message],
  );
}
