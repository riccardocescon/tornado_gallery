import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/managers/decrypt_job_manager.dart';
import 'package:tornado_img_app/core/domain/usecases/create_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/delete_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/move_images_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/rename_folder_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';
import 'package:tornado_img_app/core/domain/entities/import_image_asset.dart';

part 'archive_page_bloc.freezed.dart';
part 'archive_page_event.dart';
part 'archive_page_state.dart';
part 'archive_page_bloc_utils.dart';

class ArchivePageBloc extends Bloc<ArchivePageEvent, ArchivePageState> {
  final images = <EncryptedImage>[];
  final deletingImagesQueue = <String>[];

  /// Images the decrypt FAB acts on: at the root (mixed view) only the images
  /// directly at root level of both stores; inside a folder, that folder and
  /// its subfolders recursively.
  List<EncryptedImage> get currentFolderImages {
    if (_currentIsPrivate == null) {
      return ArchiveTreeUtils.imagesAtLevel(
        images,
        isPrivate: null,
        currentPath: '',
      );
    }
    return ArchiveTreeUtils.imagesUnder(
      images,
      isPrivate: _currentIsPrivate!,
      relativePath: _currentPath,
    );
  }

  bool get hasAllDecrypted {
    final scoped = currentFolderImages;
    return scoped.isNotEmpty && scoped.every((img) => img.decryptInfo != null);
  }

  bool _isSelectionMode = false;

  /// Current navigation location. [_currentPath] is relative to the store root
  /// ('' == root). [_currentIsPrivate] is null at the root (which shows both
  /// stores) and fixed to the entered folder's store otherwise.
  String _currentPath = '';
  bool? _currentIsPrivate;

  /// Folder the archive view is currently inside ('' == root).
  String get currentPath => _currentPath;

  /// Store of the folder currently entered, or null at the root (mixed view).
  bool? get currentIsPrivate => _currentIsPrivate;

  /// Decrypt-job key for the folder currently entered. At the root (mixed view,
  /// [_currentIsPrivate] == null) a dedicated `'root'` key is used.
  String get _currentFolderKey =>
      _currentIsPrivate == null
          ? 'root'
          : DecryptJobManager.keyFor(
            isPrivate: _currentIsPrivate!,
            relativePath: _currentPath,
          );

  /// Whether the archive is currently in multi-select mode. Exposed so the view
  /// can decide back-navigation without depending on the transient emitted
  /// state (which may briefly be non-`ui` mid-operation).
  bool get isSelectionMode => _isSelectionMode;

  /// Folders created in-session that may still be empty, so they show up
  /// before any image lives in them.
  final Set<FolderKey> _createdFolders = <FolderKey>{};

  final GalleryReaderUseCase galleryReaderUseCase;
  final ImageDeleterUseCase imageDeleterUseCase;

  final AppBloc appBloc;
  final DecryptJobManager decryptJobManager;

  /// Live subscription to background decrypt progress; re-emits the view on tick.
  StreamSubscription<void>? _decryptSub;

  final ImageSaverUseCase imageSaverUseCase;
  final CreateFolderUseCase createFolderUseCase;
  final RenameFolderUseCase renameFolderUseCase;
  final DeleteFolderUseCase deleteFolderUseCase;
  final MoveImagesUseCase moveImagesUseCase;

  ArchivePageBloc({
    required this.appBloc,
    required this.decryptJobManager,
    required this.galleryReaderUseCase,
    required this.imageDeleterUseCase,
    required this.imageSaverUseCase,
    required this.createFolderUseCase,
    required this.renameFolderUseCase,
    required this.deleteFolderUseCase,
    required this.moveImagesUseCase,
  }) : super(const ArchivePageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const ArchivePageState.loading());

      bool hasFailure = false;
      final galleryStream = galleryReaderUseCase.call(null);
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

      await for (final rel in galleryReaderUseCase.readPrivateFolderPaths()) {
        _createdFolders.add((isPrivate: true, relativePath: rel));
      }

      await for (final rel in galleryReaderUseCase.readPublicFolderPaths()) {
        _createdFolders.add((isPrivate: false, relativePath: rel));
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
              appLogger.log(
                'Image already exists in gallery, skipping add: ${value.image.storagePath.file.path}',
                LogLayer.pageBloc,
              );
            }
          },
          updatedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) =>
                  img.storagePath.path == value.oldIdentifier ||
                  img.storagePath.assetId == value.oldIdentifier ||
                  img.storagePath.file.path == value.oldIdentifier,
            );
            if (index != -1) {
              images[index] = value.image;
            } else {
              appLogger.log(
                'Updated image not found, adding as new',
                LogLayer.pageBloc,
                error: value.oldIdentifier,
              );
              images.add(value.image);
            }
            _emit(emit);
          },
          removedGalleryImage: (value) {
            final index = images.indexWhere(
              (img) =>
                  img.storagePath.path == value.path ||
                  img.storagePath.assetId == value.path ||
                  img.storagePath.file.path == value.path,
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
              appLogger.log(
                'Removed image not found in gallery, skipping remove: ${value.path}',
                LogLayer.pageBloc,
              );
            }
          },
          orElse: () {},
        );
      }
    });
    on<_ArchivePageDelete>((event, emit) async {
      deletingImagesQueue.addAll(
        event.images.map(
          (img) => img.storagePath.assetId ?? img.storagePath.path,
        ),
      );
      emit(ArchivePageState.deleting(paths: List.from(deletingImagesQueue)));
      final result = await imageDeleterUseCase.call(
        ImageDeleterParams(images: event.images),
      );

      result.fold(
        (failure) {
          appLogger.log(
            'Failed to delete image',
            LogLayer.pageBloc,
            error: failure.message,
          );
          emit(ArchivePageState.failure(message: failure.message));
        },
        (deleted) {
          if (deleted) {
            for (final image in event.images) {
              final resolvedPath = _resolveRemovalPath(image);

              if (resolvedPath == null) {
                appLogger.log(
                  'Delete succeeded but image path was not found in AppBloc',
                  LogLayer.pageBloc,
                  error:
                      'path=${image.storagePath.path}, assetId=${image.storagePath.assetId}',
                );
                continue;
              }

              appBloc.add(AppEvent.removeEncryptedImage(path: resolvedPath));
            }
          } else {
            _emit(emit);
          }
        },
      );
    });
    on<_ArchivePageEncryptAll>((event, emit) async {
      // Stop any background decrypt for this folder before re-locking.
      decryptJobManager.cancel(_currentFolderKey);
      for (final image in currentFolderImages) {
        appBloc.add(
          AppEvent.setDecryptedInfo(
            path: image.storagePath.path,
            decryptedInfo: null,
          ),
        );
      }
      _emit(emit);
    });
    on<_ArchivePageDecryptAll>((event, emit) async {
      // Kick off a background job for the current folder and return at once; the
      // manager decrypts off-loop (in parallel with other folders) and progress
      // flows back via the [decryptJobManager.updates] subscription.
      decryptJobManager.start(
        key: _currentFolderKey,
        images: currentFolderImages,
        password: event.passphrase,
      );
      _emit(emit);
    });
    on<_ImportImages>((event, emit) async {
      emit(const ArchivePageState.importing());

      final rel = event.targetRelativePath;
      final hasRel = rel.trim().isNotEmpty;

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
                  path:
                      hasRel
                          ? '${await GalleryPathProvider.getPrivateFolderPath()}/$rel'
                          : await GalleryPathProvider.getPrivateFolderPath(),
                )
                : ImageSaverParams.gallery(
                  bytes: bytes,
                  fileName: fileName,
                  album:
                      hasRel
                          ? '${Constants.appFolderName}/$rel'
                          : Constants.appFolderName,
                );
        final result = await imageSaverUseCase.call(params);
        if (result.isLeft()) {
          appLogger.log(
            'Failed to import image: $fileName',
            LogLayer.pageBloc,
            error: result.left.message,
          );
        } else {
          final hash = ByteModeling.generateHash(bytes);
          final rootDirPath =
              event.saveToGallery
                  ? await GalleryPathProvider.getPublicFolderPath()
                  : await GalleryPathProvider.getPrivateFolderPath();
          final path =
              hasRel ? '$rootDirPath/$rel/$fileName' : '$rootDirPath/$fileName';

          final String? galleryAssetId =
              event.saveToGallery
                  ? await GalleryPathProvider.findAssetIdByName(fileName)
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
    on<_RefreshView>(_onRefreshView);
    on<_ActivateSelectionMode>(_onActivateSelectionMode);
    on<_CancelSelectionMode>(_onCancelSelectionMode);
    on<_EnterFolder>(_onEnterFolder);
    on<_GoUp>(_onGoUp);
    on<_CreateFolder>(_onCreateFolder);
    on<_RenameFolder>(_onRenameFolder);
    on<_DeleteFolder>(_onDeleteFolder);
    on<_MoveImages>(_onMoveImages);
    on<_DecryptFolder>(_onDecryptFolder);

    // Background decrypt progress → refresh the view (folder tiles + FAB).
    _decryptSub = decryptJobManager.updates.listen(
      (_) => add(const ArchivePageEvent.refreshView()),
    );
  }

  @override
  Future<void> close() {
    _decryptSub?.cancel();
    return super.close();
  }

  // ── Folder navigation ───────────────────────────────────────────────────────

  void _onEnterFolder(_EnterFolder event, Emitter<ArchivePageState> emit) {
    _currentPath = event.relativePath;
    _currentIsPrivate = event.isPrivate;
    _isSelectionMode = false;
    _emit(emit);
  }

  void _onGoUp(_GoUp event, Emitter<ArchivePageState> emit) {
    if (_currentPath.isEmpty) {
      _currentIsPrivate = null;
      _emit(emit);
      return;
    }
    final parts = _currentPath.split('/')..removeLast();
    _currentPath = parts.join('/');
    if (_currentPath.isEmpty) _currentIsPrivate = null;
    _isSelectionMode = false;
    _emit(emit);
  }

  // ── Folder management ───────────────────────────────────────────────────────

  Future<void> _onCreateFolder(
    _CreateFolder event,
    Emitter<ArchivePageState> emit,
  ) async {
    // Inside a folder the store is fixed; at the root (mixed view) the user
    // picks it explicitly via [event.isPrivate], defaulting to private.
    final isPrivate = event.isPrivate ?? _currentIsPrivate ?? true;
    final result = await createFolderUseCase.call(
      CreateFolderParams(
        parentRelativePath: _currentPath,
        name: event.name,
        isPrivate: isPrivate,
      ),
    );
    result.fold(
      (failure) => emit(ArchivePageState.failure(message: failure.message)),
      (_) {
        final safeName = FileNameUtils.sanitizeFileStem(event.name);
        final rel = _currentPath.isEmpty ? safeName : '$_currentPath/$safeName';
        _createdFolders.add((isPrivate: isPrivate, relativePath: rel));
        appBloc.add(
          AppEvent.folderCreated(isPrivate: isPrivate, relativePath: rel),
        );
        _emit(emit);
      },
    );
  }

  Future<void> _onRenameFolder(
    _RenameFolder event,
    Emitter<ArchivePageState> emit,
  ) async {
    final result = await renameFolderUseCase.call(
      RenameFolderParams(
        relativePath: event.relativePath,
        newName: event.newName,
        isPrivate: event.isPrivate,
      ),
    );
    if (result.isLeft()) {
      emit(ArchivePageState.failure(message: result.left.message));
      return;
    }

    final oldRel = event.relativePath;
    final parent = (oldRel.split('/')..removeLast()).join('/');
    final safeName = FileNameUtils.sanitizeFileStem(event.newName);
    final newRel = parent.isEmpty ? safeName : '$parent/$safeName';

    // Rewrite in-memory paths for affected images so the tree updates
    // immediately (no app restart). Applies to both stores: the private store
    // is rooted at `/encrypted/`, the gallery at `/<appFolder>/`. Without this
    // the stale old-path entries keep deriving the old folder while the watcher
    // adds the renamed images, leaving both folders visible. The watcher dedups
    // the renamed entries by file path, so no duplicates result.
    final marker =
        event.isPrivate ? '/encrypted/' : '/${Constants.appFolderName}/';
    final affected =
        images
            .where(
              (img) =>
                  img.storagePath.isPrivateFolder == event.isPrivate &&
                  (img.storeRelativeDir == oldRel ||
                      img.storeRelativeDir.startsWith('$oldRel/')),
            )
            .toList();
    for (final img in affected) {
      final path = img.storagePath.path.replaceAll('\\', '/');
      final mi = path.lastIndexOf(marker);
      if (mi == -1) continue;
      final head = path.substring(0, mi + marker.length);
      final rest = path.substring(mi + marker.length); // oldRel/.../file
      final newPath = head + newRel + rest.substring(oldRel.length);
      final updated = img.copyWith(
        storagePath: img.storagePath.copyWith(path: newPath),
      );
      appBloc.add(
        AppEvent.updateEncryptedImage(
          oldIdentifier: img.storagePath.path,
          image: updated,
        ),
      );
    }

    // Re-register in-session created folders (incl. empty ones) under the new
    // name so they stay visible after the rename.
    final renamedCreated =
        _createdFolders
            .where(
              (f) =>
                  f.isPrivate == event.isPrivate &&
                  (f.relativePath == oldRel ||
                      f.relativePath.startsWith('$oldRel/')),
            )
            .toList();
    _createdFolders.removeWhere(
      (f) =>
          f.isPrivate == event.isPrivate &&
          (f.relativePath == oldRel || f.relativePath.startsWith('$oldRel/')),
    );
    for (final f in renamedCreated) {
      final swapped = newRel + f.relativePath.substring(oldRel.length);
      _createdFolders.add((isPrivate: event.isPrivate, relativePath: swapped));
    }
    _createdFolders.add((isPrivate: event.isPrivate, relativePath: newRel));

    appBloc.add(
      AppEvent.folderDeleted(isPrivate: event.isPrivate, relativePath: oldRel),
    );
    appBloc.add(
      AppEvent.folderCreated(isPrivate: event.isPrivate, relativePath: newRel),
    );

    _emit(emit);
  }

  Future<void> _onDeleteFolder(
    _DeleteFolder event,
    Emitter<ArchivePageState> emit,
  ) async {
    final contained = ArchiveTreeUtils.imagesUnder(
      images,
      isPrivate: event.isPrivate,
      relativePath: event.relativePath,
    );

    // Snapshot for rollback: the Android public delete sweeps MediaStore and
    // can take seconds. Awaiting it before touching the view froze the folder
    // on screen until completion (only a restart showed it gone). Instead
    // remove optimistically, run the delete in the background, and restore the
    // snapshot if it fails.
    final removedImages = List<EncryptedImage>.from(contained);
    final removedFolders =
        _createdFolders
            .where(
              (f) =>
                  f.isPrivate == event.isPrivate &&
                  (f.relativePath == event.relativePath ||
                      f.relativePath.startsWith('${event.relativePath}/')),
            )
            .toList();

    for (final img in removedImages) {
      images.removeWhere(
        (i) =>
            i.storagePath.path == img.storagePath.path ||
            (img.storagePath.assetId != null &&
                i.storagePath.assetId == img.storagePath.assetId),
      );
      appBloc.add(
        AppEvent.removeEncryptedImage(
          path: img.storagePath.assetId ?? img.storagePath.path,
        ),
      );
    }
    _createdFolders.removeWhere(
      (f) =>
          f.isPrivate == event.isPrivate &&
          (f.relativePath == event.relativePath ||
              f.relativePath.startsWith('${event.relativePath}/')),
    );
    appBloc.add(
      AppEvent.folderDeleted(
        isPrivate: event.isPrivate,
        relativePath: event.relativePath,
      ),
    );
    _emit(emit);

    final result = await deleteFolderUseCase.call(
      DeleteFolderParams(
        relativePath: event.relativePath,
        isPrivate: event.isPrivate,
        contained: contained,
      ),
    );
    result.fold(
      (failure) {
        // Rollback: restore the removed images and folders, then surface the
        // failure. `failure` only triggers a snackbar in the view; the trailing
        // `_emit` re-renders the restored `ui` state so the folder reappears.
        images.addAll(removedImages);
        for (final img in removedImages) {
          appBloc.add(AppEvent.addEncryptedImage(image: img));
        }
        _createdFolders.addAll(removedFolders);
        appBloc.add(
          AppEvent.folderCreated(
            isPrivate: event.isPrivate,
            relativePath: event.relativePath,
          ),
        );
        emit(ArchivePageState.failure(message: failure.message));
        _emit(emit);
      },
      (_) {},
    );
  }

  Future<void> _onMoveImages(
    _MoveImages event,
    Emitter<ArchivePageState> emit,
  ) async {
    final result = await moveImagesUseCase.call(
      MoveImagesParams(
        images: event.images,
        targetRelativePath: event.targetRelativePath,
      ),
    );
    result.fold(
      (failure) => emit(ArchivePageState.failure(message: failure.message)),
      (moveResult) {
        // Apply new private paths to the in-memory model immediately; gallery
        // moves are reflected once the watcher/poller refreshes.
        for (final img in event.images) {
          final newPath = moveResult.movedPrivatePaths[img.storagePath.path];
          if (newPath == null) continue;
          final updated = img.copyWith(
            storagePath: img.storagePath.copyWith(path: newPath),
          );
          appBloc.add(
            AppEvent.updateEncryptedImage(
              oldIdentifier: img.storagePath.path,
              image: updated,
            ),
          );
        }
        _isSelectionMode = false;
        _emit(emit);
      },
    );
  }

  void _onDecryptFolder(_DecryptFolder event, Emitter<ArchivePageState> emit) {
    final folderImages = ArchiveTreeUtils.imagesUnder(
      images,
      isPrivate: event.isPrivate,
      relativePath: event.relativePath,
    );

    // Background job keyed by this folder so it runs in parallel with others
    // and survives navigating away.
    decryptJobManager.start(
      key: DecryptJobManager.keyFor(
        isPrivate: event.isPrivate,
        relativePath: event.relativePath,
      ),
      images: folderImages,
      password: event.passphrase,
    );
    _emit(emit);
  }

  List<String> folderRelativePaths({required bool isPrivate}) =>
      _createdFolders
          .where((f) => f.isPrivate == isPrivate)
          .map((f) => f.relativePath)
          .toList();

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
    final levelImages = ArchiveTreeUtils.imagesAtLevel(
      sortedImages,
      isPrivate: _currentIsPrivate,
      currentPath: _currentPath,
    );
    final folders = ArchiveTreeUtils.foldersAtLevel(
      images,
      _createdFolders,
      isPrivate: _currentIsPrivate,
      currentPath: _currentPath,
      jobFor:
          (isPrivate, relativePath) => decryptJobManager.jobState(
            DecryptJobManager.keyFor(
              isPrivate: isPrivate,
              relativePath: relativePath,
            ),
          ),
    );
    final breadcrumb =
        _currentPath.isEmpty ? const <String>[] : _currentPath.split('/');

    emit(
      ArchivePageState.ui(
        images: levelImages,
        folders: folders,
        breadcrumb: breadcrumb,
        currentPath: _currentPath,
        currentIsPrivate: _currentIsPrivate,
        isSelectionMode: _isSelectionMode,
        activeJob: decryptJobManager.jobState(_currentFolderKey),
      ),
    );
  }

  /// Re-derives the browsable `ui` state from the bloc's retained data. Used
  /// when the page is re-opened while the bloc is resting in a terminal state
  /// (e.g. a `failure` from a folder op) so the archive never renders blank.
  void _onRefreshView(_RefreshView event, Emitter<ArchivePageState> emit) {
    _emit(emit);
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

  String? _resolveRemovalPath(EncryptedImage image) {
    // Preferisci assetId come identificatore stabile su iOS.
    final assetId = image.storagePath.assetId;
    if (assetId != null) return assetId;

    final direct = appBloc.encryptedImages.firstWhereOrNull(
      (img) => img.storagePath.path == image.storagePath.path,
    );
    return direct?.storagePath.path;
  }
}
