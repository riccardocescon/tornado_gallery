import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';


part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final EncryptImageUseCase encryptUseCase;

  GalleryBloc(this.encryptUseCase) : super(const GalleryState.initial()) {
    on<_EncryptImage>(_onEncryptImage);
  }

  Future<void> _onEncryptImage(
    _EncryptImage event,
    Emitter<GalleryState> emit,
  ) async {
    emit(const GalleryState.loading());

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
      (_) => emit(const GalleryState.encrypted()),
    );
  }
}
