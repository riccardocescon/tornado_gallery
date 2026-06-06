import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

part 'encrypted_image_page_bloc.freezed.dart';
part 'encrypted_image_page_event.dart';
part 'encrypted_image_page_state.dart';

class EncryptedImagePageBloc
    extends Bloc<EncryptedImagePageEvent, EncryptedImagePageState> {
  String password = '';
  late EncryptedImage image;

  StreamManager<AppState>? _streamManager;

  late AppBloc appBloc;
  late GalleryBloc galleryBloc;
  final ImageSaverUsecase imageSaverUsecase;
  final ImageRenamerUsecase imageRenamerUsecase;

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }

  EncryptedImagePageBloc({
    required this.appBloc,
    required this.galleryBloc,
    required this.imageSaverUsecase,
    required this.imageRenamerUsecase,
  })
    : super(const EncryptedImagePageState.initial()) {
    on<_Setup>((event, emit) async {
      image = appBloc.encryptedImages.firstWhere(
        (img) => img.storagePath.file.path == event.imagePath,
      );

      emit(EncryptedImagePageState.ui(image: image));

      _streamManager = StreamManager.fromStream(appBloc.stream);
      await for (final state in _streamManager!.stream) {
        state.maybeMap(
          updatedGalleryImage: (value) {
            if (value.image.storagePath.file.path != event.imagePath) return;

            image = value.image;
            emit(EncryptedImagePageState.ui(image: image));
          },
          orElse: () => null,
        );
      }

    });
    on<_UpdatePassword>((event, emit) => password = event.password);
    on<_Decrypt>((event, emit) async {
      emit(const EncryptedImagePageState.loading());

      if (password.isEmpty) {
        emit(
          const EncryptedImagePageState.failure(
            message: 'Password cannot be empty',
          ),
        );
        return;
      }

      galleryBloc.add(
        GalleryEvent.decryptImages(image: [image], password: password),
      );

      await for (final state in galleryBloc.stream) {
        final completed = state.maybeMap(
          decrypted: (value) {
            final decryptedImage = value.dearchivingState.dearchivedImages
                .firstWhereOrNull(
                  (e) => e.storagePath.file.path == image.storagePath.file.path,
                );
            if (decryptedImage != null) {
              appBloc.add(
                AppEvent.setDecryptedInfo(
                  path: decryptedImage.storagePath.path,
                  decryptedInfo: decryptedImage.decryptInfo!,
                ),
              );
              emit(EncryptedImagePageState.ui(image: decryptedImage));
            }
            return decryptedImage != null;
          },
          decryptionFailure: (value) {
            emit(
              EncryptedImagePageState.failure(message: value.failure.message),
            );
            return true;
          },
          orElse: () => false,
        );

        if (completed) break;
      }
      
    });
    on<_Restore>((event, emit) {
      image = image.overrideWith(decryptInfo: null);
      appBloc.add(
        AppEvent.setDecryptedInfo(path: image.storagePath.path, decryptedInfo: null),
      );
      emit(EncryptedImagePageState.ui(image: image));
    });
    on<_Rename>((event, emit) async {
      emit(const EncryptedImagePageState.loading());

      final parts = image.storagePath.path.split('/');
      final oldFileName = parts.removeLast();
      final ext = oldFileName.split('.').last;
      final path = parts.join('/');

      final foRename = await imageRenamerUsecase.call(
        ImageRenamerParams(
          path: path,
          oldFileName: oldFileName,
          newFileName: '${event.newName}.$ext',
          assetId: image.storagePath.assetId,
          bytes: image.encryptedInfo.bytes,
          album: Constants.appFolderName,
        ),
      );

      foRename.fold(
        (failure) => emit(EncryptedImagePageState.failure(message: failure.message)),
        (result) {
          if (!result.success) {
            emit(const EncryptedImagePageState.failure(message: 'Unable to rename this image'));
            return;
          }

          final oldIdentifier = image.storagePath.assetId ?? image.storagePath.path;

          final newPath = '$path/${event.newName}.$ext';
          image = image.copyWith(
            storagePath: image.storagePath.copyWith(
              path: newPath,
              assetId: result.newAssetId ?? image.storagePath.assetId,
            ),
          );

          appBloc.add(AppEvent.updateEncryptedImage(
            image: image,
            oldIdentifier: oldIdentifier,
          ));

          emit(const EncryptedImagePageState.imageRenamed());
          emit(EncryptedImagePageState.ui(image: image));
        },
      );
    });
    on<_SaveImage>((event, emit) async {
      final bytes = image.decryptInfo?.bytes ?? image.encryptedInfo.bytes;
      final foSave = await imageSaverUsecase.call(
        ImageSaverParams.gallery(bytes: bytes, fileName: image.name),
      );
      foSave.fold(
        (failure) =>
            emit(EncryptedImagePageState.failure(message: failure.message)),
        (path) => emit(EncryptedImagePageState.imageSaved(path: image.name)),
      );
    });
  }
}
