part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryState with _$GalleryState, EquatableMixin {
  const GalleryState._();

  const factory GalleryState.initial() = _Initial;
  const factory GalleryState.loading() = _Loading;
  const factory GalleryState.loaded({
    required List<GalleryImage> images,
    required bool isLoading,
    required bool hasMore,
  }) = _Loaded;
  const factory GalleryState.encrypted() = _Encrypted;

  const factory GalleryState.permissionDenied() = _PermissionDenied;
  const factory GalleryState.encryptionFailure({
    required EncryptionFailure failure,
  }) = _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images, value.isLoading, value.hasMore],
    encrypted: (_) => [],
    permissionDenied: (_) => [],
    encryptionFailure: (value) => [value.failure],
  );
}
