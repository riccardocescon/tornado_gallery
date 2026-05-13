import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/providers.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';
import 'package:tornado_img_app/features/domain/entities/import_image_asset.dart';

part 'archive_page_bloc.freezed.dart';
part 'archive_page_event.dart';
part 'archive_page_state.dart';
part 'archive_page_bloc_utils.dart';

class ArchivePageBloc extends Bloc<ArchivePageEvent, ArchivePageState> {
  final images = <EncryptedImage>[];
  final deletingImagesQueue = <String>[];

  bool isDecryptingAllImages = false;
  bool get hasAllDecrypted => images.every((img) => img.decryptInfo != null);

  bool _isSelectionMode = false;

  final GalleryReaderUsecase galleryReaderUsecase;
  final ImageDeleterUsecase imageDeleterUsecase;

  final AppBloc appBloc;
  final GalleryBloc galleryBloc;

  final ImageSaverUsecase imageSaverUseCase;

  ArchivePageBloc({
    required this.appBloc,
    required this.galleryBloc,
    required this.galleryReaderUsecase,
    required this.imageDeleterUsecase,
    required this.imageSaverUseCase,
  })
    : super(const ArchivePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const ArchivePageState.loading());

      bool hasFailure = false;
      final galleryStream = galleryReaderUsecase.call(null);
      await for (final result in galleryStream) {
        result.fold(
          (failure) {
            hasFailure = true;
            emit(ArchivePageState.failure(message: failure.message));
          },
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
                  (img) =>
                      img.storagePath.file.path ==
                      streamImage.image!.storagePath.file.path,
                );
                images.add(streamImage.image!);
                break;
              case EncryptedStreamImageType.deletedImage:
                images.removeWhere(
                  (img) => img.storagePath.file.path == streamImage.path,
                );
                break;
            }
          },
        );
      }

      if (!hasFailure) {
        _emit(emit);
      }

      await for (final appState in appBloc.stream) {
        appState.maybeMap(
          addedGalleryImage: (value) {
            final alreadyExists = images.any(
              (img) =>
                  img.storagePath.file.path ==
                  value.image.storagePath.file.path,
            );
            if (!alreadyExists) {
              images.add(value.image);
              _emit(emit);
            } else {
              appLogger.logPageBloc(
                'Image already exists in gallery, skipping add: ${value.image.storagePath.file.path}',
              );
            }
          },
          updatedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) => img.storagePath.file.path == value.image.storagePath.file.path,
            );
            if (index != -1) {
              images[index] = value.image;
            } else {
              appLogger.logPageBloc(
                'Updated image not found in gallery, adding as new: ${value.image.storagePath.file.path}',
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
              (img) => img.storagePath.file.path == value.path,
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
      deletingImagesQueue.addAll(
        event.images.map((img) => img.storagePath.path),
      );
      emit(ArchivePageState.deleting(paths: List.from(deletingImagesQueue)));
      final result = await imageDeleterUsecase.call(
        ImageDeleterParams(images: event.images),
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
            for (final image in event.images) {
              appBloc.add(
                AppEvent.removeEncryptedImage(path: image.storagePath.path),
              );
            }
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
          AppEvent.setDecryptedInfo(
            path: image.storagePath.path,
            decryptedInfo: null,
          ),
        );
      }
      isDecryptingAllImages = false;
      _emit(emit);
    });
    on<_ArchivePageDecryptAll>((event, emit) async {

      final sortedImages = this.sortedImages;
      final sortedImagesTable = {
        for (int i = 0; i < sortedImages.length; i++) i: sortedImages[i],
      };
      sortedImages.removeWhere((img) => img.decryptInfo != null);
      bool hasRemovedImages =
          sortedImages.length != sortedImagesTable.keys.length;

      galleryBloc.add(
        GalleryEvent.decryptImages(
          image: sortedImages,
          password: event.passphrase,
        ),
      );

      isDecryptingAllImages = true;

      await for (final state in galleryBloc.stream) {
        final completed = state.maybeMap(
          decrypted: (value) {
            var dearchivingState = value.dearchivingState;

            final completed =
                dearchivingState.progress == dearchivingState.totalImages;

            if (hasRemovedImages) {
              final sortedImagesTableValues =
                  sortedImagesTable.entries.toList();
              for (final dearchivedImage in dearchivingState.dearchivedImages) {
                final item = sortedImagesTableValues.firstWhere(
                  (value) =>
                      value.value.storagePath.path ==
                      dearchivedImage.storagePath.path,
                );
                if (item.value.isDecrypted) continue;

                sortedImagesTable[item.key] = item.value.overrideWith(
                  decryptInfo: dearchivedImage.decryptInfo,
                );
              }

              dearchivingState = dearchivingState.copyWith(
                totalImages: sortedImagesTable.length,
                dearchivedImages: sortedImagesTable.values.toList(),
              );
            }

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
    on<_ImportImages>((event, emit) async {
      emit(const ArchivePageState.importing());

      for (final item in event.assets) {
        final asset = item.asset;
        final bytes = await asset.originBytes;
        if (bytes == null) continue;

        final fileName = '${item.name}.png';
        final params =
            event.saveToAppFolder
                ? ImageSaverParams.appFolder(
                  bytes: bytes,
                  fileName: fileName,
                  path: await GalleryPathProvider.getEncryptedFolderPath(),
                )
                : ImageSaverParams.gallery(
                  bytes: bytes,
                  fileName: fileName,
                  album: Constants.appFolderName,
                );
        final result = await imageSaverUseCase.call(params);
        if (result.isLeft()) {
          appLogger.logPageBloc(
            'Failed to import image: $fileName',
            error: result.left.message,
          );
        } else {
          final hash = ByteModeling.generateHash(bytes);
          final rootDirPath =
              event.saveToGallery
                  ? await GalleryPathProvider.getPublicFolderPath()
                  : await GalleryPathProvider.getEncryptedFolderPath();
          final path = '$rootDirPath/$fileName';

          final String? galleryAssetId =
              event.saveToGallery
                  ? await GalleryPathProvider.findGalleryAssetIdByName(fileName)
                  : null;

          final encryptedImage = EncryptedImage(
            storagePath: StoragePath(
              path: path,
              isPrivateFolder: event.saveToAppFolder,
              assetId: galleryAssetId,
            ),
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: DateTime.now(),
          );
          appBloc.add(AppEvent.addEncryptedImage(image: encryptedImage));
        }
      }

      emit(const ArchivePageState.imported());
    });
    on<_ActivateSelectionMode>(_onActivateSelectionMode);
    on<_CancelSelectionMode>(_onCancelSelectionMode);
  }

  List<EncryptedImage> get sortedImages {
    // TODO: optimize it by saving the sorted images based on the user filter
    // currently not existing, so its sorted by last modified date
    final sorted = List<EncryptedImage>.from(images);
    sorted.sort((a, b) {
      DateTime getDate(EncryptedImage img) {
        try {
          return img.storagePath.file.lastModifiedSync();
        } catch (_) {
          return img.date;
        }
      }

      return getDate(b).compareTo(getDate(a));
    });
    return sorted;
  }

  void _emit(Emitter<ArchivePageState> emit) {
    emit(
      ArchivePageState.ui(
        images: sortedImages,
        isSelectionMode: _isSelectionMode,
      ),
    );
  }

  void _onActivateSelectionMode(
    _ActivateSelectionMode event,
    Emitter<ArchivePageState> emit,
  ) {
    _isSelectionMode = true;
    _emit(emit);
  }

  void _onCancelSelectionMode(
    _CancelSelectionMode event,
    Emitter<ArchivePageState> emit,
  ) {
    _isSelectionMode = false;
    _emit(emit);
  }
}
