part of 'app_bloc.dart';

@Freezed(equal: false)
abstract class AppEvent with _$AppEvent, EquatableMixin {
  const AppEvent._();

  const factory AppEvent.addEncryptedImage({required EncryptedImage image}) =
      _AddEncryptedImage;

  const factory AppEvent.removeEncryptedImage({required String path}) =
      _RemoveEncryptedImage;

  const factory AppEvent.setDecryptedInfo({
    required String path,
    required BytesInfo decryptedInfo,
  }) = _SetDecryptedInfo;

  @override
  List<Object?> get props => when(
    addEncryptedImage: (image) => [image],
    removeEncryptedImage: (path) => [path],
    setDecryptedInfo: (path, decryptedInfo) => [path, decryptedInfo],
  );
}
