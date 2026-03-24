import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'homepage_bloc.freezed.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';
part 'homepage_bloc_utils.dart';

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  StreamManager<GalleryPageState>? _streamManager;

  final selectedImages = <GalleryImage>[];

final HomepageBlocUtils _utils = HomepageBlocUtils();

  late EncryptedFolder appRootFolder;

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

      await for (final _ in folderStream) {
        _emit(emit);
      }
    });

    on<_Refresh>((event, emit) async {});

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
        emit(const HomepageState.galleryImages(imagesLoaded: []));
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
      ),
    );
  }
}
