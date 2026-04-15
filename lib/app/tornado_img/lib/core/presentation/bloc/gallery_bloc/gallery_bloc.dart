import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
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

  final GetIt getIt;

  GalleryBloc({
    required this.encryptUseCase,
    required this.decryptUseCase,
    required this.getIt,
  })
    : super(const GalleryState.initial()) {
    on<_EncryptImage>(_onEncryptImage);
    on<_EncryptImages>(_onEncryptImages);
    on<_DecryptImage>(_onDecryptImage);
  }

  Future<void> _onEncryptImage(
    _EncryptImage event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loadingEncryption(total: 1));

    final encrypted = <EncryptedImage>[];
    final failed = <GalleryImage>[];
    final skippedImages = <GalleryImage>[];

    final isSkipped = _isSkipped(
      event.settings.overrideImage,
      event.settings.destinationPath,
      event.image.id,
    );

    if (isSkipped) {
      skippedImages.add(event.image);
      appLogger.logBloc(
        'Encryption skipped for ${event.image.file.path}: File already exists and override is disabled',
      );
    } else {
    

    final result = await encryptUseCase.call(
      EncryptImageParams(
        file: event.image.file,
        password: event.password,
        fileId: event.image.id,
        settings: event.settings,
      ),
    );

      result.fold(
        (_) => failed.add(event.image),
        (encryptedImage) => encrypted.add(encryptedImage),
      );
    }

    GalleryState.encrypted(
          archivingState: ArchivingState(
            totalImages: 1,
        archivedImages: List<EncryptedImage>.from(encrypted),
        skippedImages: List<GalleryImage>.from(skippedImages),
        failedImages: List<GalleryImage>.from(failed),
      ),
    );
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
          fileId: image.id,
          settings: event.settings,
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
        (encryptedImage) => encrypted.add(encryptedImage),
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

  Future<void> _onDecryptImage(
    _DecryptImage event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loadingDecryption(total: 1));
    final result = await decryptUseCase.call(
      DecryptImageParams(file: event.image.file, password: event.password),
    );

    result.fold(
      (failure) => emit(GalleryState.decryptionFailure(failure: failure)),
      (decryptedInfo) => emit(
        GalleryState.decrypted(
          archivingState: DearchivingState(
            totalImages: 1,
            dearchivedImages: [
              event.image.copyWith(decryptInfo: decryptedInfo),
            ],
            failedImages: [],
          ),
        ),
      ),
    );
  }

  bool _isSkipped(bool overrideImage, String? destinationPath, String imageId) {
    if (overrideImage) return false;

    final encryptedImages = getIt.get<AppBloc>().encryptedImages;
    final exists = encryptedImages.any(
      (img) => img.file.path == '$destinationPath/$imageId.png',
    );
    return exists;
  }
  
}
