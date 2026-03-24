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

    on<_OpenGallery>((event, emit) async {
      
      emit(const HomepageState.galleryLoading());

      final photoPermission = await Permission.photos.request();
      if (!photoPermission.isGranted && !photoPermission.isLimited) {
        emit(HomepageState.permissionDenied());
        return;
      }

      selectedImages.clear();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      appLogger.logPageBloc(
        "File picker result: ${result?.files.map((f) => f.name).toList()}",
      );


      if (result == null || result.files.isEmpty) {
        emit(const HomepageState.galleryImages(imagesLoaded: []));
        return;
      }

      for (final file in result.files) {
        final bytes = file.bytes!;
        final name = file.name;

        final saveResult = await SaverGallery.saveImage(
          bytes,
          quality: 100,
          fileName: name,
          skipIfExists: false,
        );

        if (saveResult.isSuccess) {
          appLogger.logPageBloc('Image saved successfully: $name');
          final savedAsset = await _utils.findSavedImageByName(name);
          if (savedAsset != null) {
            final savedFile = await savedAsset.file;
            if (savedFile != null) {
              final newImage = GalleryImage(
                id: savedAsset.id,
                file: savedFile,
                date: savedAsset.createDateTime,
              );
                
              // For newly saved images, insert at the top (most recent)
              selectedImages.insert(0, newImage);
            }
          } else {
            appLogger.logPageBloc(
              'Failed to find saved image asset',
              error: 'Asset not found after saving: $name',
            );
          }
        } else {
          appLogger.logPageBloc(
            'Failed to save image',
            error: saveResult.errorMessage,
          );
        }
      }

      emit(HomepageState.galleryImages(imagesLoaded: selectedImages));
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
