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
import 'package:tornado_img_app/core/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:rxdart/rxdart.dart';

part 'homepage_bloc.freezed.dart';
part 'homepage_event.dart';
part 'homepage_state.dart';
part 'homepage_bloc_utils.dart';

enum Pages {
  home(icon: Icons.home, label: 'Home'),
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

  // Folder create/delete made on the archive page. The filesystem watcher does
  // not reliably emit events for empty directories, so these runtime deltas
  // keep the folder count exact without a full disk rescan. Keys are deduped
  // against the in-memory tree at count time to avoid double counting.
  final Set<String> _runtimeFolderCreations = <String>{};
  final Set<String> _runtimeFolderRemovals = <String>{};

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
                // Rimuovi il vecchio per qualsiasi forma di identificatore
                _runtimeUpserts.removeWhere(
                  (key, img) =>
                      key == value.oldIdentifier ||
                      img.storagePath.path == value.oldIdentifier ||
                      img.storagePath.assetId == value.oldIdentifier,
                );
                _runtimeRemovals.add(value.oldIdentifier);

                // Inserisci il nuovo con chiave stabile
                final newKey = value.image.storagePath.assetId ?? value.image.storagePath.path;
                _runtimeUpserts[newKey] = value.image;
                _emit(emit);
              },
              removedGalleryImage: (value) {
                _runtimeUpserts.removeWhere(
                  (_, img) =>
                      img.storagePath.path == value.path ||
                      img.storagePath.assetId == value.path,
                );
                _runtimeRemovals.add(value.path);
                _emit(emit);
              },
              folderCreated: (value) {
                final key = _folderKey(value.isPrivate, value.relativePath);
                _runtimeFolderRemovals.remove(key);
                _runtimeFolderCreations.add(key);
                _emit(emit);
              },
              folderDeleted: (value) {
                final key = _folderKey(value.isPrivate, value.relativePath);
                // Deleting a folder removes its whole subtree, so drop any
                // in-session creations under it too.
                _runtimeFolderCreations.removeWhere(
                  (k) => k == key || k.startsWith('$key/'),
                );
                _runtimeFolderRemovals.add(key);
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
      _runtimeFolderCreations.clear();
      _runtimeFolderRemovals.clear();

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

    final mergedByKey = <String, EncryptedImage>{};
  for (final img in baseImages) {
    final key = img.storagePath.assetId ?? img.storagePath.path;
    mergedByKey[key] = img;
  }

  for (final removedKey in _runtimeRemovals) {
    mergedByKey.removeWhere(
      (key, img) =>
          key == removedKey ||
          img.storagePath.path == removedKey ||
          img.storagePath.assetId == removedKey,
    );
  }

  for (final entry in _runtimeUpserts.entries) {
    final key = entry.value.storagePath.assetId ?? entry.key;
    mergedByKey[key] = entry.value;
  }

  final images = mergedByKey.values.toList();

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
        folderLoaded: _countFolders(private, appPublicEncryptedRootFolder),
        bytesLoaded: totalBytes,
        lastLoaded: lastLoaded,
        archivingState: currentArchivingState,
      ),
    );
  }

  /// Total folder count across the private and public trees, reconciled with
  /// the runtime create/delete deltas the filesystem watcher cannot see (empty
  /// directories). Pure in-memory — no disk access.
  int _countFolders(EncryptedFolder private, EncryptedFolder? public) {
    final treeKeys = <String>{};
    _collectFolderKeys(private, private.path, true, treeKeys);
    if (public != null) {
      _collectFolderKeys(public, public.path, false, treeKeys);
    }

    var count = treeKeys.length;
    for (final key in _runtimeFolderCreations) {
      if (!treeKeys.contains(key)) count++;
    }
    // A removed folder takes its whole subtree with it: subtract every tree
    // folder that equals or lives under a removed path.
    for (final treeKey in treeKeys) {
      final removed = _runtimeFolderRemovals.any(
        (r) => treeKey == r || treeKey.startsWith('$r/'),
      );
      if (removed) count--;
    }
    return count;
  }

  void _collectFolderKeys(
    EncryptedFolder folder,
    String rootPath,
    bool isPrivate,
    Set<String> out,
  ) {
    for (final sub in folder.subfolders) {
      out.add(_folderKey(isPrivate, _relativeTo(rootPath, sub.path)));
      _collectFolderKeys(sub, rootPath, isPrivate, out);
    }
  }

  String _folderKey(bool isPrivate, String relativePath) =>
      '${isPrivate ? 1 : 0}:$relativePath';

  String _relativeTo(String rootPath, String path) {
    var root = rootPath.replaceAll('\\', '/');
    var p = path.replaceAll('\\', '/');
    if (p.startsWith(root)) p = p.substring(root.length);
    if (p.startsWith('/')) p = p.substring(1);
    return p;
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
