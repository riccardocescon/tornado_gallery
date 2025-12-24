part of 'homepage_bloc.dart';

@Freezed(equal: false)
abstract class HomepageEvent with _$HomepageEvent, EquatableMixin {
  const HomepageEvent._();

  const factory HomepageEvent.setup() = _Setup;

  @override
  List<Object?> get props => [];
}
