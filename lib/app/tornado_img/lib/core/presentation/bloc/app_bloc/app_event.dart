part of 'app_bloc.dart';

@Freezed(equal: false)
abstract class AppEvent with _$AppEvent, EquatableMixin {
  const AppEvent._();

  const factory AppEvent.addEncryptedImage({required EncryptedImage image}) =
      _AddEncryptedImage;
  const factory AppEvent.updateEncryptedImage({required EncryptedImage image, required String oldIdentifier}) =
      _UpdateEncryptedImage;

  const factory AppEvent.removeEncryptedImage({required String path}) =
      _RemoveEncryptedImage;

  const factory AppEvent.setDecryptedInfo({
    required String path,
    required BytesInfo? decryptedInfo,
  }) = _SetDecryptedInfo;

  const factory AppEvent.folderCreated({
    required bool isPrivate,
    required String relativePath,
  }) = _FolderCreated;

  const factory AppEvent.folderDeleted({
    required bool isPrivate,
    required String relativePath,
  }) = _FolderDeleted;

  @override
  List<Object?> get props => when(
    addEncryptedImage: (image) => [image],
    updateEncryptedImage: (image, oldIdentifier) => [image, oldIdentifier],
    removeEncryptedImage: (path) => [path],
    setDecryptedInfo: (path, decryptedInfo) => [path, decryptedInfo],
    folderCreated: (isPrivate, relativePath) => [isPrivate, relativePath],
    folderDeleted: (isPrivate, relativePath) => [isPrivate, relativePath],
  );
}
