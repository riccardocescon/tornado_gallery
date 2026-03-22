part of 'homepage_bloc.dart';

@Freezed(equal: false)
abstract class HomepageEvent with _$HomepageEvent, EquatableMixin {
  const HomepageEvent._();

  const factory HomepageEvent.setup() = _Setup;
  const factory HomepageEvent.openGallery() = _OpenGallery;
  const factory HomepageEvent.refresh() = _Refresh;

  @override
  List<Object?> get props => [];
}
