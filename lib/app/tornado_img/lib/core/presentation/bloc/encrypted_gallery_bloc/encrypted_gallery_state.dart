part of 'encrypted_gallery_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedGalleryState
    with _$EncryptedGalleryState, EquatableMixin {
  const EncryptedGalleryState._();

  const factory EncryptedGalleryState.initial() = _Initial;
  const factory EncryptedGalleryState.loading() = _Loading;
  const factory EncryptedGalleryState.loaded({
    required List<EncryptedImage> images,
  }) = _Loaded;
  const factory EncryptedGalleryState.decrypted({
    required EncryptedImage data,
  }) =
      _Decrypted;
  const factory EncryptedGalleryState.decryptedFolderCompleted() =
      _DecryptedFolderCompleted;
  const factory EncryptedGalleryState.folderDeleted({
    required String folderPath,
  }) = _FolderDeleted;
  const factory EncryptedGalleryState.encryptionFailure({
    required EncryptionFailure failure,
  }) = _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images],
    decrypted: (value) => [value.data],
    decryptedFolderCompleted: (_) => [],
    folderDeleted: (value) => [value.folderPath],
    encryptionFailure: (value) => [value.failure],
  );
}
