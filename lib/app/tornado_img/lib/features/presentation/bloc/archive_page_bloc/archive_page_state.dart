part of 'archive_page_bloc.dart';

@Freezed(equal: false)
abstract class ArchivePageState with _$ArchivePageState, EquatableMixin {
  const ArchivePageState._();

  const factory ArchivePageState.initial() = _Initial;
  const factory ArchivePageState.loading() = _Loading;
  const factory ArchivePageState.deleting({required List<String> paths}) =
      _Deleting;
  const factory ArchivePageState.ui({required List<EncryptedImage> images}) =
      _UI;
  const factory ArchivePageState.decryptingAllUI({
    required DearchivingState dearchivingState,
  }) = _DecryptingAllUI;
  const factory ArchivePageState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => when(
    initial: () => [],
    loading: () => [],
    deleting: (paths) => [paths],
    ui: (images) => [images],
    decryptingAllUI: (dearchivingState) => [dearchivingState],
    failure: (message) => [message],
  );
}
