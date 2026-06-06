import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final encryptedImages = <EncryptedImage>[];

  AppBloc() : super(const AppState.initial()) {
    on<_AddEncryptedImage>((event, emit) {
      final update = encryptedImages.indexWhere(
        (img) => img.storagePath.file.path == event.image.storagePath.file.path,
      );
      if (update != -1) {
        encryptedImages[update] = event.image;
        emit(AppState.updatedGalleryImage(image: event.image, oldIdentifier: event.image.storagePath.file.path));
      } else {
        encryptedImages.add(event.image);
        emit(AppState.addedGalleryImage(image: event.image));
      }
    });
   on<_UpdateEncryptedImage>((event, emit) {
      final index = encryptedImages.indexWhere(
        (img) =>
            img.storagePath.path == event.oldIdentifier ||
            img.storagePath.assetId == event.oldIdentifier ||
            img.storagePath.file.path == event.oldIdentifier,
      );

      if (index == -1) {
        appLogger.logBloc(
          'UpdateEncryptedImage failed: Image not found',
          error: event.oldIdentifier,
        );    
        return;
      }

      encryptedImages[index] = event.image;
      emit(AppState.updatedGalleryImage(image: event.image, oldIdentifier: event.oldIdentifier));
    }); 
    on<_RemoveEncryptedImage>((event, emit) {
      encryptedImages.removeWhere(
        (img) => img.storagePath.file.path == event.path,
      );
      emit(AppState.removedGalleryImage(path: event.path));
    });
    on<_SetDecryptedInfo>((event, emit) {
      final index = encryptedImages.indexWhere(
        (img) => img.storagePath.file.path == event.path,
      );
      if (index == -1) {
        appLogger.logBloc(
          'SetDecryptedInfo failed: Image not found',
          error: event.path,
        );
        return;
      }

      final image = encryptedImages[index];
      encryptedImages[index] = image.overrideWith(
        decryptInfo: event.decryptedInfo,
      );
      emit(AppState.updatedGalleryImage(image: encryptedImages[index], oldIdentifier: event.path));
    });
  }
}
