part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryState with _$GalleryState, EquatableMixin {
  const GalleryState._();

  const factory GalleryState.initial() = _Initial;
  const factory GalleryState.loadingEncryption({required int total}) =
      _LoadingEncryption;
  const factory GalleryState.loadingDecryption({required int total}) =
      _LoadingDecryption;
  const factory GalleryState.encrypted({
    required ArchivingState archivingState,
  }) = _Encrypted;
  const factory GalleryState.decrypted({
    required DearchivingState dearchivingState,
  }) = _Decrypted;
  const factory GalleryState.decryptionFailure({
    required EncryptionFailure failure,
  }) = _DecryptionFailure;

  @override
  List<Object?> get props => maybeWhen(
    initial: () => [],
    loadingEncryption: (total) => [total],
    loadingDecryption: (total) => [total],
    encrypted: (archivingState) => [archivingState],
    decrypted: (dearchivingState) => [dearchivingState],
    decryptionFailure: (failure) => [failure],
    orElse: () => [],
  );
}
