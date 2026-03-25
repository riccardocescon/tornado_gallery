import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';


part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final EncryptImageUseCase encryptUseCase;

  GalleryBloc(this.encryptUseCase) : super(const GalleryState.initial()) {
    on<_EncryptImage>(_onEncryptImage);
    on<_EncryptImages>(_onEncryptImages);
  }

  Future<void> _onEncryptImage(
    _EncryptImage event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loading(total: 1));

    final result = await encryptUseCase.call(
      EncryptImageParams(
        file: event.image.file,
        password: event.password,
        fileId: event.image.id,
        path: event.path,
      ),
    );

    result.fold(
      (failure) => emit(GalleryState.encryptionFailure(failure: failure)),
      (_) => emit(
        GalleryState.encrypted(
          archivingState: ArchivingState(
            totalImages: 1,
            archivedImages: [event.image],
            failedImages: [],
          ),
        ),
      ),
    );
  }

  Future<void> _onEncryptImages(
    _EncryptImages event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryState.loading(total: event.images.length));

    final encrypted = <GalleryImage>[];
    final failed = <GalleryImage>[];

    for (final image in event.images) {
      final result = await encryptUseCase.call(
        EncryptImageParams(
          file: image.file,
          password: event.password,
          fileId: image.id,
          path: event.path,
        ),
      );

      result.fold((_) => failed.add(image), (_) => encrypted.add(image));

      final archivingState = ArchivingState(
        archivedImages: List<GalleryImage>.from(encrypted),
        failedImages: List<GalleryImage>.from(failed),
        totalImages: event.images.length,
      );
      emit(
        GalleryState.encrypted(archivingState: archivingState)
      );
    }
  }
}
