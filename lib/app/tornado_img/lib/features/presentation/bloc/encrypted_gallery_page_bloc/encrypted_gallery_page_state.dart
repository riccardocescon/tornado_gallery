part of 'encrypted_gallery_page_bloc.dart';

@Freezed(equal: false)
abstract class EncrpytedGalleryPageState
    with _$EncrpytedGalleryPageState, EquatableMixin {
  const EncrpytedGalleryPageState._();

  const factory EncrpytedGalleryPageState.initial() = _Initial;
  const factory EncrpytedGalleryPageState.loading() = _Loading;
  const factory EncrpytedGalleryPageState.loaded({
    required List<EncryptedImage> images,
  }) = _Loaded;
  const factory EncrpytedGalleryPageState.decrypted({required Uint8List data}) =
      _Decrypted;
  const factory EncrpytedGalleryPageState.failure({required String message}) =
      _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images],
    decrypted: (value) => [value.data],
    failure: (value) => [value.message],
  );
}
