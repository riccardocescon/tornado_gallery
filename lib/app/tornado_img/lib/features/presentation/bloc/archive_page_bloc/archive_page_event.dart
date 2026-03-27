part of 'archive_page_bloc.dart';

@Freezed(equal: false)
abstract class ArchivePageEvent with _$ArchivePageEvent {
  const ArchivePageEvent._();

  const factory ArchivePageEvent.setup() = _Setup;
}
