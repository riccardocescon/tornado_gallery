part of 'homepage_bloc.dart';

@Freezed(equal: false)
abstract class HomepageEvent with _$HomepageEvent, EquatableMixin {
  const HomepageEvent._();

  const factory HomepageEvent.setup() = _Setup;
  const factory HomepageEvent.refresh() = _Refresh;
  const factory HomepageEvent.galleryAssetsSelected({
    required List<AssetEntity> imagesSelected,
  }) = _GalleryAssetsSelected;

  @override
  List<Object?> get props => [];
}
