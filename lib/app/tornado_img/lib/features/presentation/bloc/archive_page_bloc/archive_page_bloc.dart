import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';
import 'package:tornado_img_app/injection_container.dart';

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

      final galleryStream = galleryReaderUsecase.call(null);
      await for (final result in galleryStream) {
        result.fold(
          (failure) => emit(ArchivePageState.failure(message: failure.message)),
          (streamImage) {
            switch (streamImage.type) {
              case GalleryStreamImageType.newImage:
                images.add(streamImage.image!);
                getIt<AppBloc>().add(
                  AppEvent.addEncryptedImage(image: streamImage.image!),
                );
                break;
              case GalleryStreamImageType.updatedImage:
                images.removeWhere(
                  (img) => img.file.path == streamImage.image!.file.path,
                );
                images.add(streamImage.image!);
                break;
              case GalleryStreamImageType.deletedImage:
                images.removeWhere((img) => img.file.path == streamImage.path);
                break;
            }
            emit(ArchivePageState.ui(images: List.from(images)));
          },
        );
      }

      final appBloc = getIt<AppBloc>();
      await for (final appState in appBloc.stream) {
        appState.maybeMap(
          addedGalleryImage: (value) {
            final alreadyExists = images.any(
              (img) => img.file.path == value.image.file.path,
            );
            if (!alreadyExists) {
              images.add(value.image);
              emit(ArchivePageState.ui(images: List.from(images)));
            } else {
              appLogger.logPageBloc(
                'Image already exists in gallery, skipping add: ${value.image.file.path}',
              );
            }
          },
          updatedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) => img.file.path == value.image.file.path,
            );
            if (index != -1) {
              images[index] = value.image;
            } else {
              appLogger.logPageBloc(
                'Updated image not found in gallery, adding as new: ${value.image.file.path}',
              );
              images.add(value.image);
            }

            emit(ArchivePageState.ui(images: List.from(images)));
          },
          removedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) => img.file.path == value.path,
            );

            if (index != -1) {
              images.removeAt(index);
              emit(ArchivePageState.ui(images: List.from(images)));
            } else {
              appLogger.logPageBloc(
                'Removed image not found in gallery, skipping remove: ${value.path}',
              );
            }
          },
          orElse: () {},
        );
      }
      
    });
  }
}
