part of 'app_bloc.dart';

@Freezed(equal: false)
abstract class AppEvent with _$AppEvent, EquatableMixin {
  const AppEvent._();

  const factory AppEvent.addEncryptedImage({required GalleryImage image}) =
      _AddEncryptedImage;

  const factory AppEvent.removeEncryptedImage({required String path}) =
      _RemoveEncryptedImage;

  @override
  List<Object?> get props => when(
    addEncryptedImage: (image) => [image],
    removeEncryptedImage: (path) => [path],
  );
}
