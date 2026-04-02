import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:rxdart/rxdart.dart';

part 'homepage_bloc.freezed.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';
part 'homepage_bloc_utils.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  StreamManager? _streamManager;

  final selectedImages = <GalleryImage>[];

final HomepageBlocUtils _utils = HomepageBlocUtils();

  late EncryptedFolder appRootFolder;
  ArchivingState? currentArchivingState;

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }

  HomepageBloc() : super(const HomepageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const HomepageState.loading());

      appRootFolder = await _utils.loadAppRootFolder();
      
      _emit(emit);

      final folderStream = _utils.watchAppFolderChanges(appRootFolder);

      
      final taggedFolderStream = folderStream.map((e) => _FolderStream());
      final taggedGalleryStream = getIt<GalleryBloc>().stream
          .startWith(getIt<GalleryBloc>().state)
          .map((s) => _GalleryStream(s));

      final mergedStream = Rx.merge([taggedFolderStream, taggedGalleryStream]);

      _streamManager = StreamManager.fromStream(mergedStream);

      await for (final state in _streamManager!.stream) {
        switch (state) {
          case _FolderStream():
            _emit(emit);
            break;

          case _GalleryStream(:final galleryState):
            galleryState.maybeMap(
              loading: (value) {
                currentArchivingState = ArchivingState(
                  totalImages: value.total,
                  archivedImages: [],
                  failedImages: [],
                );
                _emit(emit);
              },
              encrypted: (value) {
                final archive = value.archivingState;
                final completed =
                    archive.archivedImages.length +
                        archive.failedImages.length ==
                    archive.totalImages;

                currentArchivingState = completed ? null : archive;
                _emit(emit);
              },
              orElse: () => null,
            );
            break;
        }
      }
    });

    on<_Refresh>((event, emit) async {
      await _utils.dispose();
      await _streamManager?.dispose();
      add(const HomepageEvent.setup());
    });

    on<_GalleryAssetsSelected>((event, emit) async {
      
      emit(const HomepageState.galleryLoading());

      try {
       
        selectedImages
          ..clear()
          ..addAll(await _utils.mapAssetsToGalleryImages(event.imagesSelected));

        emit(
          HomepageState.galleryImages(imagesLoaded: List.of(selectedImages)),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error opening gallery with photo_manager picker',
          error: e.toString(),
        );
        emit(HomepageState.galleryImages(imagesLoaded: []));
      }
    });
  }

  void _emit(Emitter<HomepageState> emit) {
    final totalImages = appRootFolder.subfolders.fold<int>(
      appRootFolder.images.length,
      (previousValue, folder) => previousValue + folder.images.length,
    );

    final totalBytes = appRootFolder.subfolders.fold<int>(
      appRootFolder.images.fold<int>(
        0,
        (prev, image) => prev + image.file.lengthSync(),
      ),
      (prev, folder) =>
          prev +
          folder.images.fold<int>(
            0,
            (prev2, image) => prev2 + image.file.lengthSync(),
          ),
    );

    final lastLoaded =
        appRootFolder.images.isNotEmpty
            ? appRootFolder.images
                .map((img) => img.date)
                .reduce((a, b) => a.isAfter(b) ? a : b)
            : null;

    emit(
      HomepageState.galleryStatus(
        imagesLoaded: totalImages,
        folderLoaded: appRootFolder.subfolders.length,
        bytesLoaded: totalBytes,
        lastLoaded: lastLoaded,
        archivingState: currentArchivingState,
      ),
    );
  }
}
