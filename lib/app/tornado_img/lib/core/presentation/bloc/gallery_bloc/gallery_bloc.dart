import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';


part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final EncryptImageUseCase encryptUseCase;
  final DecryptImageUseCase decryptUseCase;

  final AppBloc appBloc;


  GalleryBloc({
    required this.encryptUseCase,
    required this.decryptUseCase,
    required this.appBloc,
  })
    : super(const GalleryState.initial()) {
    on<_EncryptImages>(_onEncryptImages);
    on<_DecryptImages>(_onDecryptImages);
  }

  Future<void> _onEncryptImages(
    _EncryptImages event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loadingEncryption(total: event.images.length));

    final encrypted = <EncryptedImage>[];
    final failed = <GalleryImage>[];
    final skippedImages = <GalleryImage>[];

    for (final image in event.images) {

      final skipped = _isSkipped(
        event.settings.overrideImage,
        event.settings.destinationPath,
        image.id,
      );

      if (skipped) {
        skippedImages.add(image);
        appLogger.logBloc(
          'Encryption skipped for ${image.file.path}: File already exists and override is disabled',
        );
      } else {
        final result = await encryptUseCase.call(
        EncryptImageParams(
          file: image.file,
          password: event.password,
            fileId: event.filename ?? image.id,
          settings: event.settings,
            assetId: image.id,
        ),
      );

      result.fold(
        (error) {
          failed.add(image);
          appLogger.logBloc(
            'Encryption failed for ${image.file.path}',
            error: error.message,
          );
        },
          (encryptedImage) {
            encrypted.add(encryptedImage);
            appBloc.add(AppEvent.addEncryptedImage(image: encryptedImage));
          },
      );
      }

      final archivingState = ArchivingState(
        archivedImages: List<EncryptedImage>.from(encrypted),
        failedImages: List<GalleryImage>.from(failed),
        skippedImages: List<GalleryImage>.from(skippedImages),
        totalImages: event.images.length,
      );
      emit(
        GalleryState.encrypted(archivingState: archivingState)
      );
    }
  }

  Future<void> _onDecryptImages(
    _DecryptImages event,
    Emitter<GalleryState> emit,
  ) async {
    final totalImages = event.image.length;
    emit(GalleryState.loadingDecryption(total: totalImages));

    final loading = event.image.where((e) => e.decryptInfo == null).toList();
    final dearchived = event.image.where((e) => e.decryptInfo != null).toList();
    final failed = <EncryptedImage>[];

    emit(
      GalleryState.decrypted(
        dearchivingState: DearchivingState(
          totalImages: totalImages,
          loadingImages: loading.toList(),
          dearchivedImages: dearchived.toList(),
          failedImages: failed.toList(),
        ),
      ),
    );

    for (final image in event.image) {
      final result = await decryptUseCase.call(
        DecryptImageParams(
          file: image.storagePath.file,
          password: event.password,
        ),
      );

      loading.remove(image);

      if (result.isLeft()) {
        failed.add(image);
      } else {
        final updatedImage = image.copyWith(decryptInfo: result.right);
        dearchived.add(updatedImage);
        appBloc.add(
          AppEvent.setDecryptedInfo(
            path: updatedImage.storagePath.path,
            decryptedInfo: result.right,
          ),
        );
      }

      emit(
        GalleryState.decrypted(
          dearchivingState: DearchivingState(
            totalImages: totalImages,
            loadingImages: loading.toList(),
            dearchivedImages: dearchived.toList(),
            failedImages: failed.toList(),
          ),
        ),
      );
    }
  }

  bool _isSkipped(bool overrideImage, String? destinationPath, String imageId) {
    if (overrideImage) return false;

    final encryptedImages = appBloc.encryptedImages;
    final exists = encryptedImages.any(
      (img) => img.storagePath.file.path == '$destinationPath/$imageId.png',
    );
    return exists;
  }
  
}
