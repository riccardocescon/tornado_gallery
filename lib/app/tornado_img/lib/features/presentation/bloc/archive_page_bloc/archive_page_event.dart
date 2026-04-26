part of 'archive_page_bloc.dart';

@Freezed(equal: false)
abstract class ArchivePageEvent with _$ArchivePageEvent {
  const ArchivePageEvent._();

  const factory ArchivePageEvent.setup() = _Setup;

  const factory ArchivePageEvent.delete({
    required String path,
    String? assetId,
  }) = _ArchivePageDelete;

  const factory ArchivePageEvent.encryptAll() = _ArchivePageEncryptAll;
  const factory ArchivePageEvent.decryptAll({required String passphrase}) =
      _ArchivePageDecryptAll;
}
