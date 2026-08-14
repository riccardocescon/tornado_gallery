part of 'encryption_page_bloc.dart';

@Freezed(equal: false)
abstract class EncryptionPageState with _$EncryptionPageState, EquatableMixin {
  const EncryptionPageState._();

  const factory EncryptionPageState.initial() = _Initial;
  const factory EncryptionPageState.loading() = _Loading;
  const factory EncryptionPageState.ui({
    required List<GalleryImage> images,
    required String fileName,
    required String size,
    required String dateTime,
  }) = _UI;
  const factory EncryptionPageState.settingsUi({
    required EncryptionSettings settings,
  }) = _SettingsUI;
  const factory EncryptionPageState.encrypting({
    required ArchivingState? archivingState,
  }) = _Encrypting;
  const factory EncryptionPageState.encrypted() = _Encrypted;

  /// The free image cap would be exceeded. Not a [failure]: it is an offer, and
  /// the UI answers it with the paywall rather than an error.
  const factory EncryptionPageState.limitReached() = _LimitReached;

  const factory EncryptionPageState.failure({required String message}) =
      _Failure;

  @override
  List<Object?> get props => when(
    initial: () => [],
    loading: () => [],
    ui:
        (images, fileName, size, dateTime) => [
          images,
          fileName,
          size,
          dateTime,
        ],
    settingsUi: (settings) => [settings],
    encrypting: (archivingState) => [archivingState],
    encrypted: () => [],
    limitReached: () => [],
    failure: (message) => [message],
  );
}
