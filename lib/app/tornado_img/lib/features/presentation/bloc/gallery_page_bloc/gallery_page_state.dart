part of 'gallery_page_bloc.dart';

@Freezed(equal: false)
abstract class GalleryPageState with _$GalleryPageState, EquatableMixin {
  const GalleryPageState._();

  const factory GalleryPageState.initial() = _Initial;
  const factory GalleryPageState.loading() = _Loading;
  const factory GalleryPageState.loaded({required List<GalleryImage> images}) =
      _Loaded;
  const factory GalleryPageState.encrypted() = _Encrypted;
  const factory GalleryPageState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images],
    encrypted: (_) => [],
    failure: (value) => [value.message],
  );
}
