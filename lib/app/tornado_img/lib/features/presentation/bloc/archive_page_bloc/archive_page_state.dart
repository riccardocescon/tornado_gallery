part of 'archive_page_bloc.dart';

@Freezed(equal: false)
abstract class ArchivePageState with _$ArchivePageState, EquatableMixin {
  const ArchivePageState._();

  const factory ArchivePageState.initial() = _Initial;
  const factory ArchivePageState.loading() = _Loading;
  const factory ArchivePageState.importing() = _Importing;
  const factory ArchivePageState.deleting({required List<String> paths}) =
      _Deleting;
  const factory ArchivePageState.ui({
    required List<EncryptedImage> images,
    @Default(<ArchiveFolderView>[]) List<ArchiveFolderView> folders,
    @Default(<String>[]) List<String> breadcrumb,
    @Default('') String currentPath,
    bool? currentIsPrivate,
    @Default(false) bool isSelectionMode,
    DearchivingState? activeJob,
  }) = _UI;
  const factory ArchivePageState.imported() = _Imported;
  const factory ArchivePageState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => when(
    initial: () => [],
    loading: () => [],
    deleting: (paths) => [paths],
    ui:
        (
          images,
          folders,
          breadcrumb,
          currentPath,
          currentIsPrivate,
          isSelectionMode,
          activeJob,
        ) => [
          images,
          folders,
          breadcrumb,
          currentPath,
          currentIsPrivate,
          isSelectionMode,
          activeJob,
        ],
    importing: () => [],
    imported: () => [],
    failure: (message) => [message],
  );
}
