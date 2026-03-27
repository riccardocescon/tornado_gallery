import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

part 'archive_page_bloc.freezed.dart';
part 'archive_page_event.dart';
part 'archive_page_state.dart';
part 'archive_page_bloc_utils.dart';

class ArchivePageBloc extends Bloc<ArchivePageEvent, ArchivePageState> {
  final images = <GalleryImage>[];

  final GalleryReaderUsecase galleryReaderUsecase;

  // final ArchivePageBlocUtils _utils = ArchivePageBlocUtils();

  ArchivePageBloc({required this.galleryReaderUsecase})
    : super(const ArchivePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const ArchivePageState.loading());
      // TODO: add realtime-listener for in-session changes in the gallery and public folders
      final galleryStream = galleryReaderUsecase.call(null);
      await for (final result in galleryStream) {
        result.fold(
          (failure) => emit(ArchivePageState.failure(message: failure.message)),
          (image) {
            images.add(image);
            emit(ArchivePageState.ui(images: List.from(images)));
          },
        );
      }
    });
  }
}
