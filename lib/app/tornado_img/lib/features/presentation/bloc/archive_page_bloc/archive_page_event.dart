part of 'archive_page_bloc.dart';

@Freezed(equal: false)
abstract class ArchivePageEvent with _$ArchivePageEvent {
  const ArchivePageEvent._();

  const factory ArchivePageEvent.setup() = _Setup;

  const factory ArchivePageEvent.importImages({
    required List<ImportImageAsset> assets,
    required bool saveToAppFolder,
    required bool saveToGallery,
    @Default('') String targetRelativePath,
  }) = _ImportImages;

  const factory ArchivePageEvent.delete({
    required List<EncryptedImage> images,
  }) = _ArchivePageDelete;

  const factory ArchivePageEvent.encryptAll() = _ArchivePageEncryptAll;
  const factory ArchivePageEvent.decryptAll({required String passphrase}) =
      _ArchivePageDecryptAll;

  /// Re-emits the browsable `ui` state from retained data. Dispatched when the
  /// page re-opens while the bloc rests in a terminal state (e.g. `failure`).
  const factory ArchivePageEvent.refreshView() = _RefreshView;

  const factory ArchivePageEvent.activateSelectionMode() =
      _ActivateSelectionMode;
  const factory ArchivePageEvent.cancelSelectionMode() = _CancelSelectionMode;

  // ── Folder navigation & management ──────────────────────────────────────────

  const factory ArchivePageEvent.enterFolder({
    required String relativePath,
    required bool isPrivate,
  }) = _EnterFolder;

  const factory ArchivePageEvent.goUp() = _GoUp;

  const factory ArchivePageEvent.createFolder({
    required String name,
    bool? isPrivate,
  }) = _CreateFolder;

  const factory ArchivePageEvent.renameFolder({
    required String relativePath,
    required bool isPrivate,
    required String newName,
  }) = _RenameFolder;

  const factory ArchivePageEvent.deleteFolder({
    required String relativePath,
    required bool isPrivate,
  }) = _DeleteFolder;

  const factory ArchivePageEvent.moveImages({
    required List<EncryptedImage> images,
    required String targetRelativePath,
  }) = _MoveImages;

  const factory ArchivePageEvent.decryptFolder({
    required String relativePath,
    required bool isPrivate,
    required String passphrase,
  }) = _DecryptFolder;
}
