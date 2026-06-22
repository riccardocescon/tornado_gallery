import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/usecases/create_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/delete_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/move_images_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/rename_folder_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
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

  bool isDecryptingAllImages = false;

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

  /// Folders created in-session that may still be empty, so they show up
  /// before any image lives in them.
  final Set<FolderKey> _createdFolders = <FolderKey>{};

  final GalleryReaderUsecase galleryReaderUsecase;
  final ImageDeleterUsecase imageDeleterUsecase;

  final AppBloc appBloc;
  final GalleryBloc galleryBloc;

  final ImageSaverUsecase imageSaverUseCase;
  final CreateFolderUsecase createFolderUsecase;
  final RenameFolderUsecase renameFolderUsecase;
  final DeleteFolderUsecase deleteFolderUsecase;
  final MoveImagesUsecase moveImagesUsecase;

  ArchivePageBloc({
    required this.appBloc,
    required this.galleryBloc,
    required this.galleryReaderUsecase,
    required this.imageDeleterUsecase,
    required this.imageSaverUseCase,
    required this.createFolderUsecase,
    required this.renameFolderUsecase,
    required this.deleteFolderUsecase,
    required this.moveImagesUsecase,
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

      await for (final rel in galleryReaderUsecase.readPrivateFolderPaths()) {
        _createdFolders.add((isPrivate: true, relativePath: rel));
      }

      await for (final rel in galleryReaderUsecase.readPublicFolderPaths()) {
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
              appLogger.logPageBloc(
                'Image already exists in gallery, skipping add: ${value.image.storagePath.file.path}',
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
              appLogger.logPageBloc(
                'Updated image not found, adding as new',
                error: value.oldIdentifier,
              );
              images.add(value.image);
            }
            if (isDecryptingAllImages) return;
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
                emit(ArchivePageState.deleting(paths: List.from(deletingImagesQueue)));
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
        event.images.map((img) => img.storagePath.assetId ?? img.storagePath.path),
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
              final resolvedPath = _resolveRemovalPath(image);

              if (resolvedPath == null) {
                appLogger.logPageBloc(
                  'Delete succeeded but image path was not found in AppBloc',
                  error:
                      'path=${image.storagePath.path}, assetId=${image.storagePath.assetId}',
                );
                continue;
              }

              appBloc.add(
                AppEvent.removeEncryptedImage(path: resolvedPath),
              );
            }
          } else {
            _emit(emit);
          }
        },
      );
    });
    on<_ArchivePageEncryptAll>((event, emit) async {
      for (final image in currentFolderImages) {
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

      final scopedPaths =
          currentFolderImages.map((i) => i.storagePath.path).toSet();
      final sortedImages = this.sortedImages
          .where((img) => scopedPaths.contains(img.storagePath.path))
          .toList();
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
        if (completed) break;
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
                  path: await GalleryPathProvider.getPrivateFolderPath(),
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
                  : await GalleryPathProvider.getPrivateFolderPath();
          final path = '$rootDirPath/$fileName';

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
    on<_ActivateSelectionMode>(_onActivateSelectionMode);
    on<_CancelSelectionMode>(_onCancelSelectionMode);
    on<_EnterFolder>(_onEnterFolder);
    on<_GoUp>(_onGoUp);
    on<_CreateFolder>(_onCreateFolder);
    on<_RenameFolder>(_onRenameFolder);
    on<_DeleteFolder>(_onDeleteFolder);
    on<_MoveImages>(_onMoveImages);
    on<_DecryptFolder>(_onDecryptFolder);
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
    final result = await createFolderUsecase.call(
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
        final rel =
            _currentPath.isEmpty ? safeName : '$_currentPath/$safeName';
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
    final result = await renameFolderUsecase.call(
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
    final affected = images
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
    final renamedCreated = _createdFolders
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
    final result = await deleteFolderUsecase.call(
      DeleteFolderParams(
        relativePath: event.relativePath,
        isPrivate: event.isPrivate,
        contained: contained,
      ),
    );
    result.fold(
      (failure) => emit(ArchivePageState.failure(message: failure.message)),
      (_) {
        for (final img in contained) {
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
      },
    );
  }

  Future<void> _onMoveImages(
    _MoveImages event,
    Emitter<ArchivePageState> emit,
  ) async {
    final result = await moveImagesUsecase.call(
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

  Future<void> _onDecryptFolder(
    _DecryptFolder event,
    Emitter<ArchivePageState> emit,
  ) async {
    final folderImages = ArchiveTreeUtils.imagesUnder(
      images,
      isPrivate: event.isPrivate,
      relativePath: event.relativePath,
    )..removeWhere((img) => img.decryptInfo != null);

    if (folderImages.isEmpty) {
      _emit(emit);
      return;
    }

    galleryBloc.add(
      GalleryEvent.decryptImages(
        image: folderImages,
        password: event.passphrase,
      ),
    );

    isDecryptingAllImages = true;

    await for (final state in galleryBloc.stream) {
      final completed = state.maybeMap(
        decrypted: (value) {
          final dearchivingState = value.dearchivingState;
          emit(
            ArchivePageState.decryptingAllUI(
              dearchivingState: dearchivingState,
            ),
          );
          return dearchivingState.progress == dearchivingState.totalImages;
        },
        orElse: () => false,
      );
      if (completed) break;
    }

    isDecryptingAllImages = false;
    _emit(emit);
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
    );
    final breadcrumb = _currentPath.isEmpty
        ? const <String>[]
        : _currentPath.split('/');

    emit(
      ArchivePageState.ui(
        images: levelImages,
        folders: folders,
        breadcrumb: breadcrumb,
        currentPath: _currentPath,
        currentIsPrivate: _currentIsPrivate,
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
