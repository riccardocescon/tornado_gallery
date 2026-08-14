part of 'homepage_bloc.dart';

@Freezed(equal: false)
abstract class HomepageState with _$HomepageState, EquatableMixin {
  const HomepageState._();

  const factory HomepageState.initial() = _Initial;
  const factory HomepageState.loading() = _Loading;
  const factory HomepageState.galleryLoading() = _GalleryLoading;
  const factory HomepageState.galleryImages({
    required List<GalleryImage> imagesLoaded,
  }) = _GalleryImages;
  const factory HomepageState.galleryStatus({
    required int imagesLoaded,
    required int folderLoaded,
    required int bytesLoaded,
    required DateTime? lastLoaded,
    required ArchivingState? archivingState,
  }) = _GalleryStatus;
  const factory HomepageState.loaded({
    required List<GalleryImage>? images,
    required List<EncryptedEntity>? encryptedImages,
  }) = _Loaded;
  const factory HomepageState.homepageSet({required Pages page}) = _HomepageSet;
  const factory HomepageState.failure({required String message}) = _Failure;

  @override
  List<Object?> get props => when(
    initial: () => [],
    loading: () => [],
    galleryLoading: () => [],
    galleryImages: (imagesLoaded) => [imagesLoaded],
    galleryStatus:
        (imagesLoaded, folderLoaded, bytesLoaded, lastLoaded, archivingState) =>
            [
              imagesLoaded,
              folderLoaded,
              bytesLoaded,
              lastLoaded,
              archivingState,
            ],
    loaded: (images, encryptedImages) => [images, encryptedImages],
    homepageSet: (page) => [page],
    failure: (message) => [message],
  );
}
