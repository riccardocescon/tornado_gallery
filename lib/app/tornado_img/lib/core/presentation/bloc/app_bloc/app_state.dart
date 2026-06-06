part of 'app_bloc.dart';

@Freezed(equal: false)
abstract class AppState with _$AppState, EquatableMixin {
  const AppState._();

  const factory AppState.initial() = _Initial;
  const factory AppState.addedGalleryImage({required EncryptedImage image}) =
      _Added;
  const factory AppState.updatedGalleryImage({required EncryptedImage image, required String oldIdentifier}) =
      _Updated;
  const factory AppState.removedGalleryImage({required String path}) = _Removed;

  @override
  List<Object?> get props => maybeWhen(
    addedGalleryImage: (image) => [image],
    updatedGalleryImage: (image, oldIdentifier) => [image, oldIdentifier],
    removedGalleryImage: (path) => [path],
    orElse: () => [],
  );
}
