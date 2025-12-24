part of 'encrypted_gallery_bloc.dart';

@Freezed(equal: false)
abstract class EncryptedGalleryState
    with _$EncryptedGalleryState, EquatableMixin {
  const EncryptedGalleryState._();

  const factory EncryptedGalleryState.initial() = _Initial;
  const factory EncryptedGalleryState.loading() = _Loading;
  const factory EncryptedGalleryState.loaded({
    required List<EncryptedImage> images,
    required bool isLoading,
    required bool hasMore,
  }) = _Loaded;
  const factory EncryptedGalleryState.decrypted({required Uint8List data}) =
      _Decrypted;

  const factory EncryptedGalleryState.permissionDenied() = _PermissionDenied;
  const factory EncryptedGalleryState.encryptionFailure({
    required EncryptionFailure failure,
  }) = _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images, value.isLoading, value.hasMore],
    decrypted: (value) => [value.data],
    permissionDenied: (_) => [],
    encryptionFailure: (value) => [value.failure],
  );
}
