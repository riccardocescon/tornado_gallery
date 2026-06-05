import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/app_folder_streamer_usecase.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
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

enum Pages {
  home(icon: Icons.home, label: 'Home'),
  archive(icon: Icons.lock_rounded, label: 'Archive'),
  settings(icon: Icons.settings, label: 'Settings');

  const Pages({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class HomepageBloc extends Bloc<HomepageEvent, HomepageState> {
  StreamManager? _streamManager;
  bool _refreshInFlight = false;
  final Map<String, EncryptedImage> _runtimeUpserts =
      <String, EncryptedImage>{};
  final Set<String> _runtimeRemovals = <String>{};

  final selectedImages = <GalleryImage>[];
  Pages currentPage = Pages.home;

  final AppRepository _repo;
  final AppFolderStreamerUsecase _folderStreamer;

  EncryptedFolder? appEncryptedRootFolder;
  EncryptedFolder? appPublicEncryptedRootFolder;
  ArchivingState? currentArchivingState;

  @override
  Future<void> close() {
    _folderStreamer.dispose();
    _streamManager?.dispose();
    return super.close();
  }

  HomepageBloc({
    required AppRepository appRepository,
    required AppFolderStreamerUsecase folderStreamer,
  }) : _repo = appRepository,
       _folderStreamer = folderStreamer,
       super(const HomepageState.initial()) {
    on<_Setup>((event, emit) async {
      if (_streamManager != null) return;
      emit(const HomepageState.loading());

      final taggedFolderStream = _folderStreamer.call().map(
        (folders) =>
            _FolderStream(privateFolder: folders.$1, publicFolder: folders.$2),
      );

      final taggedGalleryStream = getIt<GalleryBloc>().stream
          .startWith(getIt<GalleryBloc>().state)
          .map((s) => _GalleryStream(s));

      final taggedAppStream = getIt<AppBloc>().stream
          .startWith(getIt<AppBloc>().state)
          .map((s) => _AppStream(s));

      final mergedStream = Rx.merge([
        taggedFolderStream,
        taggedGalleryStream,
        taggedAppStream,
      ]);

      _streamManager = StreamManager.fromStream(mergedStream);

      await for (final state in _streamManager!.stream) {
        switch (state) {
          case _FolderStream(:final privateFolder, :final publicFolder):
            appEncryptedRootFolder = privateFolder;
            appPublicEncryptedRootFolder = publicFolder;
            _emit(emit);
            break;

          case _GalleryStream(:final galleryState):
            galleryState.maybeMap(
              loadingEncryption: (value) {
                currentArchivingState = ArchivingState.init(
                  totalImages: value.total,
                );
                _emit(emit);
              },
              encrypted: (value) {
                final archive = value.archivingState;
                final wasArchiving = currentArchivingState != null;
                final completed =
                    archive.progress ==
                    archive.totalImages;

                appPublicEncryptedRootFolder =
                    _folderStreamer.mergeArchivedPublicImages(
                      currentPublicFolder: appPublicEncryptedRootFolder,
                      archivedImages: archive.archivedImages,
                    );

                currentArchivingState = completed ? null : archive;
                _emit(emit);

                if (completed && wasArchiving) {
                  add(const HomepageEvent.refresh());
                }
              },
              orElse: () => null,
            );
            break;

          case _AppStream(:final appState):
            appState.maybeMap(
              addedGalleryImage: (value) {
                _runtimeRemovals.remove(value.image.storagePath.path);
                _runtimeUpserts[value.image.storagePath.path] = value.image;
                _emit(emit);
              },
              updatedGalleryImage: (value) {
                _runtimeRemovals.remove(value.image.storagePath.path);
                _runtimeUpserts[value.image.storagePath.path] = value.image;
                _emit(emit);
              },
              removedGalleryImage: (value) {
                _runtimeUpserts.remove(value.path);
                _runtimeRemovals.add(value.path);
                _emit(emit);
              },
              orElse: () => null,
            );
            break;
        }
      }
    });

    on<_Refresh>((event, emit) async {
      if (_refreshInFlight) return;
      _refreshInFlight = true;

      try {
      await _repo.dispose();
      await _folderStreamer.dispose();
      await _streamManager?.dispose();
      _streamManager = null;

      // Force an immediate snapshot refresh to reconcile latest storage state.
        appEncryptedRootFolder = await _repo.loadPrivateRootFolder();
      appPublicEncryptedRootFolder = await _repo.loadPublicRootFolder();
      if (appPublicEncryptedRootFolder == null) {
        final created = await _repo.createPublicFolder();
        if (created) {
          appPublicEncryptedRootFolder = await _repo.loadPublicRootFolder();
        }
      }

      // Fresh repository snapshot is authoritative after a manual refresh.
      _runtimeUpserts.clear();
      _runtimeRemovals.clear();

      _emit(emit);

      add(const HomepageEvent.setup());
      } finally {
        _refreshInFlight = false;
      }
    });

    on<_GalleryAssetsSelected>((event, emit) async {
      emit(const HomepageState.galleryLoading());

      try {
        selectedImages
          ..clear()
          ..addAll(await _repo.mapAssetsToGalleryImages(event.imagesSelected));

        emit(
          HomepageState.galleryImages(imagesLoaded: List.of(selectedImages)),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error opening gallery with photo_manager picker',
          error: e.toString(),
        );
        emit(HomepageState.failure(message: e.toString()));
      }
    });

    on<_SetScreen>((event, emit) {
      currentPage = event.page;
      emit(HomepageState.homepageSet(page: event.page));

      if (currentPage == Pages.home) _emit(emit);
    });
  }

  void _emit(Emitter<HomepageState> emit) {
    final private = appEncryptedRootFolder;
    if (private == null) return;

    final subFolders =
        private.subfolders + (appPublicEncryptedRootFolder?.subfolders ?? []);

    final baseImages =
        private.images + (appPublicEncryptedRootFolder?.images ?? []);

    final mergedByPath = <String, EncryptedImage>{
      for (final img in baseImages) img.storagePath.path: img,
    };

    for (final removedPath in _runtimeRemovals) {
      mergedByPath.remove(removedPath);
    }
    mergedByPath.addAll(_runtimeUpserts);

    final images = mergedByPath.values.toList();

    final totalImages = subFolders.fold<int>(
      images.length,
      (previousValue, folder) => previousValue + folder.images.length,
    );

    final totalBytes = _sumImagesBytes(images) + _sumFoldersBytes(subFolders);

    final lastLoaded =
        images.isNotEmpty
            ? images
                .map((img) => img.date)
                .reduce((a, b) => a.isAfter(b) ? a : b)
            : null;

    emit(
      HomepageState.galleryStatus(
        imagesLoaded: totalImages,
        folderLoaded: private.subfolders.length + 1,
        bytesLoaded: totalBytes,
        lastLoaded: lastLoaded,
        archivingState: currentArchivingState,
      ),
    );
  }

  int _sumFoldersBytes(List<EncryptedFolder> folders) {
    return folders.fold<int>(
      0,
      (total, folder) => total + _sumImagesBytes(folder.images),
    );
  }

  int _sumImagesBytes(List<EncryptedImage> images) {
    return images.fold<int>(
      0,
      (total, image) => total + _safeFileLength(image),
    );
  }

  int _safeFileLength(EncryptedImage image) {
    try {
      final file = image.storagePath.file;
      if (!file.existsSync()) return image.encryptedInfo.bytes.length;
      return file.lengthSync();
    } catch (_) {
      return image.encryptedInfo.bytes.length;
    }
  }
}
