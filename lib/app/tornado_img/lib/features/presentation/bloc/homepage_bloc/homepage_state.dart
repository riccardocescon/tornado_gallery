part of 'homepage_bloc.dart';

@Freezed(equal: false)
abstract class HomepageState with _$HomepageState, EquatableMixin {
  const HomepageState._();

  const factory HomepageState.initial() = _Initial;
  const factory HomepageState.loading() = _Loading;
  const factory HomepageState.loaded({
    required List<GalleryImage>? images,
    required List<EncryptedImage>? encryptedImages,
  }) = _Loaded;
  const factory HomepageState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => map(
    initial: (_) => [],
    loading: (_) => [],
    loaded: (value) => [value.images, value.encryptedImages],
    failure: (value) => [value.message],
  );
}
