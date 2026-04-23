import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/features/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

part 'archive_page_bloc.freezed.dart';
part 'archive_page_event.dart';
part 'archive_page_state.dart';
part 'archive_page_bloc_utils.dart';

class ArchivePageBloc extends Bloc<ArchivePageEvent, ArchivePageState> {
  final images = <EncryptedImage>[];
  final deletingImagesQueue = <String>[];

  bool isDecryptingAllImages = false;
  bool get hasAllDecrypted => images.every((img) => img.decryptInfo != null);

  final GalleryReaderUsecase galleryReaderUsecase;
  final ImageDeleterUsecase imageDeleterUsecase;

  final AppBloc appBloc;
  final GalleryBloc galleryBloc;

  ArchivePageBloc({
    required this.appBloc,
    required this.galleryBloc,
    required this.galleryReaderUsecase,
    required this.imageDeleterUsecase,
  })
    : super(const ArchivePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const ArchivePageState.loading());

      final galleryStream = galleryReaderUsecase.call(null);
      await for (final result in galleryStream) {
        result.fold(
          (failure) => emit(ArchivePageState.failure(message: failure.message)),
          (streamImage) {
            switch (streamImage.type) {
              case EncryptedStreamImageType.newImage:
                images.add(streamImage.image!);
                appBloc.add(
                  AppEvent.addEncryptedImage(image: streamImage.image!),
                );
                break;
              case EncryptedStreamImageType.updatedImage:
                images.removeWhere(
                  (img) => img.file.path == streamImage.image!.file.path,
                );
                images.add(streamImage.image!);
                break;
              case EncryptedStreamImageType.deletedImage:
                images.removeWhere((img) => img.file.path == streamImage.path);
                break;
            }

            _emit(emit);
          },
        );
      }

      await for (final appState in appBloc.stream) {
        appState.maybeMap(
          addedGalleryImage: (value) {
            final alreadyExists = images.any(
              (img) => img.file.path == value.image.file.path,
            );
            if (!alreadyExists) {
              images.add(value.image);
              _emit(emit);
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

            // Prevent a UI build if all images are decrypting
            // this would override the state and the loading indicator would never show
            if (isDecryptingAllImages) return;

            _emit(emit);
          },
          removedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) => img.file.path == value.path,
            );

            if (index != -1) {
              images.removeAt(index);
              deletingImagesQueue.remove(value.path);
              _emit(emit);
              if (deletingImagesQueue.isNotEmpty) {
                emit(
                  ArchivePageState.deleting(
                    paths: List.from(deletingImagesQueue),
                  ),
                );
              }
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
    on<_ArchivePageDelete>((event, emit) async {
      deletingImagesQueue.add(event.path);
      emit(ArchivePageState.deleting(paths: List.from(deletingImagesQueue)));
      final result = await imageDeleterUsecase.call(
        ImageDeleterParams(path: event.path, assetId: event.assetId),
      );

      result.fold(
        (failure) {
          appLogger.logPageBloc(
            'Failed to delete image',
            error: failure.message,
          );
          emit(ArchivePageState.failure(message: failure.message));
        },
        (deleted) {
          if (deleted) {
            appBloc.add(AppEvent.removeEncryptedImage(path: event.path));
          } else {
            _emit(emit);
          }
        },
      );
    });
    on<_ArchivePageEncryptAll>((event, emit) async {
      for (int i = 0; i < images.length; i++) {
        final image = images[i].overrideWith(decryptInfo: null);

        appBloc.add(
          AppEvent.setDecryptedInfo(path: image.path, decryptedInfo: null),
        );
      }
      isDecryptingAllImages = false;
      _emit(emit);
    });
    on<_ArchivePageDecryptAll>((event, emit) async {
      galleryBloc.add(
        GalleryEvent.decryptImages(image: images, password: event.passphrase),
      );

      isDecryptingAllImages = true;

      await for (final state in galleryBloc.stream) {
        final completed = state.maybeMap(
          decrypted: (value) {
            final dearchivingState = value.dearchivingState;

            final completed =
                dearchivingState.progress == dearchivingState.totalImages;

            emit(
              ArchivePageState.decryptingAllUI(
                dearchivingState: dearchivingState,
              ),
            );

            return completed;
          },
          orElse: () => false,
        );
        if (completed) return;
      }

      isDecryptingAllImages = false;
    });
  }

  void _emit(Emitter<ArchivePageState> emit) {
    // TODO: optimize it by saving the sorted images based on the user filter
    // currently not sxisting, so its sorted by last modified date
    final sortedImages = List<EncryptedImage>.from(images)..sort(
      (a, b) => b.file.lastModifiedSync().compareTo(a.file.lastModifiedSync()),
    );

    emit(ArchivePageState.ui(images: sortedImages));
  }
}
