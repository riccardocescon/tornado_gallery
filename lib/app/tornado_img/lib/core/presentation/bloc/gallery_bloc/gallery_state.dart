part of 'gallery_bloc.dart';

@Freezed(equal: false)
abstract class GalleryState with _$GalleryState, EquatableMixin {
  const GalleryState._();

  const factory GalleryState.initial() = _Initial;
  const factory GalleryState.loading({required int total}) = _Loading;
  const factory GalleryState.encrypted({
    required ArchivingState archivingState,
  }) = _Encrypted;
  const factory GalleryState.encryptionFailure({
    required EncryptionFailure failure,
  }) = _Failure;

  @override
  List<Object?> get props => maybeWhen(
    initial: () => [],
    loading: (total) => [total],
    encrypted: (archivingState) => [archivingState],
    encryptionFailure: (failure) => [failure],
    orElse: () => [],
  );
}
