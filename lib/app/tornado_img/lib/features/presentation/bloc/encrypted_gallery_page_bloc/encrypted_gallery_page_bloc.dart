import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'encrypted_gallery_page_event.dart';
part 'encrypted_gallery_page_state.dart';
part 'encrypted_gallery_page_bloc.freezed.dart';
part 'encrypted_gallery_page_bloc_utils.dart';

class EncrpytedGalleryPageBloc
    extends Bloc<EncrpytedGalleryPageEvent, EncrpytedGalleryPageState> {
  // Page-specific state
  final int _pageSize = 10;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<EncryptedEntity> _entities = [];
  Directory? _album;
  String? _root;

  final _EncryptedGalleryPageBlocUtils _utils =
      _EncryptedGalleryPageBlocUtils();
  
  StreamManager<EncryptedGalleryState>? _streamManager;

  // Delegate to core bloc for operations
  final encryptedGalleryBloc = getIt<EncryptedGalleryBloc>();

  // Getters
  String? get root => _root;
  List<EncryptedImage> get images =>
      _entities.whereType<EncryptedImage>().toList();
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<Directory> get encryptedFolder async {
    final baseDir = await encryptedGalleryBloc.repository.getEncryptedFolder();
    if (_root != null) {
      return Directory('${baseDir.path}/$_root');
    }
    return baseDir;
  }

  @override
  Future<void> close() {
    _streamManager?.dispose();
    return super.close();
  }

  EncrpytedGalleryPageBloc()
    : super(const EncrpytedGalleryPageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const EncrpytedGalleryPageState.loading());

      // Set the current route
      _root = event.currentRoute;

      final encryptedDir = await encryptedFolder;

      final albums = encryptedDir.listSync().toList();

      if (albums.isEmpty) {
        _isLoading = false;
        _hasMore = false;
        _emit(emit);
      } else {
        _album = encryptedDir;
        _entities.clear();
        _currentPage = 0;
        _hasMore = true;

        add(const EncrpytedGalleryPageEvent.loadNextPage());
      }

      _streamManager = StreamManager<EncryptedGalleryState>();
      _streamManager!.addStream(encryptedGalleryBloc.stream);

      await for (final state in _streamManager!.stream) {
        state.maybeMap(
          decrypted: (value) {
            final updatedImage = value.data.copyWith();
            final index = _entities.indexWhere(
              (entity) =>
                  !entity.isFolder && entity.asImage.id == updatedImage.id,
            );
            if (index != -1) {
              _entities[index] = updatedImage;
            } else {
              _entities.add(updatedImage);
            }

            _emit(emit);
          },
          folderDeleted: (value) {
            final deletedFolderPath = value.folderPath;
            _entities.removeWhere((entity) {
              return entity.isFolder &&
                  entity.asFolder.path.endsWith(deletedFolderPath);
            });
            _emit(emit);
          },
          orElse: () {},
        );
      }
    });

    on<_LoadNextPage>((event, emit) async {
      if (_isLoading || !_hasMore) return;

      emit(const EncrpytedGalleryPageState.loading());
      _isLoading = true;

      final files =
          _album!.listSync().toList()..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

      // Filter out files/folders that no longer exist
      final validFiles = files.where((file) => file.existsSync()).toList();

      if (validFiles.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        _emit(emit);
        return;
      }

      final start = _currentPage * _pageSize;
      final end = (_currentPage + 1) * _pageSize;
      final pageFiles = validFiles.sublist(
        start,
        end > validFiles.length ? validFiles.length : end,
      );

      if (pageFiles.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        _emit(emit);
        return;
      }

      // Insert all entities, preserving cached decrypt state from the global bloc
      final foldersList = <EncryptedFolder>[];

      for (final fileSystem in pageFiles) {
        final fileName = fileSystem.path.split('/').last;
        final date = fileSystem.statSync().modified;
        final file = File(fileSystem.path);
        if (fileName.contains('.')) {
          final existing =
              encryptedGalleryBloc.images
                  .where((img) => img.file.path == file.path)
                  .firstOrNull;
          final image =
              existing ?? EncryptedImage(id: fileName, file: file, date: date);
          _utils.insertImageSorted(_entities, image);
        } else {
          foldersList.add(EncryptedFolder.empty(fileSystem.path));
        }
      }

      for (final folder in foldersList) {
        _utils.insertFolderSorted(_entities, folder);
      }

      _currentPage++;
      _isLoading = false;
      _emit(emit);
    });

    on<_DeleteImage>((event, emit) async {
      try {
        emit(const EncrpytedGalleryPageState.loading());
        await event.image.file.delete();
        _entities.remove(event.image);
        _emit(emit);
      } catch (e) {
        log('Error deleting image: $e');
        emit(
          EncrpytedGalleryPageState.failure(
            message: 'Error deleting image: $e',
          ),
        );
      }
    });

    on<_DeleteFolder>((event, emit) async {
      // Just delegate to global bloc, it will handle the deletion and notification
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.deleteFolderGlobal(folderName: event.folderName),
      );
      
      // If we are in the deleted folder, emit folderDeleted state to navigate back
      if (_root == event.folderName ||
          (_root != null && _root!.endsWith(event.folderName))) {
        emit(const EncrpytedGalleryPageState.folderDeleted());
      }
    });

    on<_CreateFolder>((event, emit) async {
      emit(const EncrpytedGalleryPageState.loading());
      final encryptedDir = await encryptedFolder;
      Directory folderPath = Directory(
        '${encryptedDir.path}/${event.folderName}',
      );

      if (await folderPath.exists()) {
        log('Folder already exists: ${event.folderName}');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        folderPath = Directory(
          '${encryptedDir.path}/${event.folderName}-$timestamp',
        );
      }

      try {
        await folderPath.create(recursive: true);
        
        // Create the EncryptedFolder entity and add it to the list
        final newFolder = EncryptedFolder.empty(folderPath.path);
        
        // Insert in correct alphabetical position among folders
        _utils.insertFolderSorted(_entities, newFolder);
        
        _emit(emit);
      } catch (e) {
        log('Error creating folder: $e');
        emit(
          EncrpytedGalleryPageState.failure(
            message: 'Error creating folder: $e',
          ),
        );
      }
    });

    on<_DecryptImage>((event, emit) async {
      emit(const EncrpytedGalleryPageState.loading());

      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decryptImage(
          image: event.image,
          password: event.password,
        ),
      );

      await for (final cryptoState in encryptedGalleryBloc.stream) {
        final completed = cryptoState.maybeMap(
          decrypted: (value) {
            emit(
              EncrpytedGalleryPageState.decrypted(
                data: value.data.decryptedBytes!,
              ),
            );

            return true;
          },
          encryptionFailure: (value) {
            emit(
              EncrpytedGalleryPageState.failure(message: value.failure.message),
            );
            return true;
          },
          orElse: () => false,
        );

        if (completed) break;
      }
    });

    on<_DecryptFolder>((event, emit) async {
      emit(const EncrpytedGalleryPageState.loading());
      final imagesToDecrypt =
          images.where((e) => e.decryptedBytes == null).toList();

      if (imagesToDecrypt.isEmpty) {
        emit(
          const EncrpytedGalleryPageState.failure(
            message: 'No images to decrypt',
          ),
        );
        return;
      }

      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decryptFolder(
          images: imagesToDecrypt,
          password: event.password,
        ),
      );

      await for (final cryptoState in encryptedGalleryBloc.stream) {
        final completed = cryptoState.maybeMap(
          decryptedFolderCompleted: (value) => true,
          encryptionFailure: (value) {
            emit(
              EncrpytedGalleryPageState.failure(message: value.failure.message),
            );
            return false;
          },
          orElse: () => false,
        );

        if (completed) break;
      }
    });
  }


  void _emit(Emitter<EncrpytedGalleryPageState> emit) {
    emit(
      EncrpytedGalleryPageState.loaded(
        entities: List<EncryptedEntity>.from(_entities),
        isLoading: _isLoading,
        hasMore: _hasMore,
      ),
    );
  }
}
