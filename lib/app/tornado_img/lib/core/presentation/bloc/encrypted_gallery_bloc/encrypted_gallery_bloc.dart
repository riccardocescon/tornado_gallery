import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';
import 'package:image/image.dart' as img;

part 'encrypted_gallery_bloc.freezed.dart';
part 'encrypted_gallery_event.dart';
part 'encrypted_gallery_state.dart';
part 'encrypted_gallery_bloc_utils.dart';

// Top-level function for isolate decryption
typedef DecryptionTask = ({img.Image image, CryptoConfig config});

Future<CryptoResult> _decryptImageInIsolate(DecryptionTask task) async {
  return await ImageCrypto.decryptImageObject(
    image: task.image,
    config: task.config,
  );
}

class EncryptedGalleryBloc
    extends Bloc<EncryptedGalleryEvent, EncryptedGalleryState> {
  String? root;

  final int _pageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _entities = <EncryptedEntity>[];

  StreamManager<FileSystemEvent>? _streamManager;

  List<EncryptedImage> get images =>
      List<EncryptedImage>.from(_entities.whereType<EncryptedImage>());
  List<EncryptedEntity> get entities => _entities.toList();
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  final _EncryptedGalleryBlocUtils _utils = _EncryptedGalleryBlocUtils();

  Future<Directory> get encryptedFolder async {
    final appDir = await getApplicationDocumentsDirectory();
    String path = '${appDir.path}/encrypted';
    if (root != null) {
      path += '/$root';
    }
    final encryptedDir = Directory(path);
    if (!encryptedDir.existsSync()) {
      await encryptedDir.create(recursive: true);
    }

    return encryptedDir;
  }

  // Cache album to reuse on pagination
  late FileSystemEntity _album;

  

  @override
  Future<void> close() async {
    await _streamManager?.dispose();
    super.close();
  }

  EncryptedGalleryBloc() : super(const EncryptedGalleryState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const EncryptedGalleryState.loading());

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

        add(const EncryptedGalleryEvent.loadNextPage());
      }

      _streamManager?.dispose();
      _streamManager = StreamManager.fromStream(encryptedDir.watch());
      await for (final state in _streamManager!.stream) {
        if (state is FileSystemCreateEvent || state is FileSystemModifyEvent) {
          log('File system event: ${state.runtimeType} - ${state.path}');
          final fileName = state.path.split('/').last;
          final date = DateTime.now();
          final isFile = fileName.contains('.');
          if (isFile) {
            final file = File(state.path);
            final imageIndex = _entities.indexWhere(
              (image) => image.tryImage?.id == fileName,
            );
            if (imageIndex != -1) {
              _entities[imageIndex] = EncryptedImage(
                id: fileName,
                file: file,
                date: date,
              );
            } else {
              _entities.add(
                EncryptedImage(id: fileName, file: file, date: date),
              );
            }
          } else {
            final dir = Directory(state.path);
            final folderIndex = _entities.indexWhere(
              (image) => image.tryFolder?.name == dir.path.split('/').last,
            );
            if (folderIndex != -1) {
              _entities[folderIndex] = EncryptedFolder.empty(dir.path);
            } else {
              _entities.add(EncryptedFolder.empty(dir.path));
            }
          }

          _emit(emit);
          continue;
        }

        if (state is FileSystemDeleteEvent) {
          _entities.removeWhere(
            (image) =>
                (image.isImage && image.asImage.file.path == state.path) ||
                (image.isFolder &&
                    image.asFolder.name == state.path.split('/').last),
          );
          _emit(emit);
          continue;
        }
      }

      log(
        'File system watcher set up for encrypted gallery at ${encryptedDir.path}',
      );
    });

    on<_LoadNextPage>((event, emit) async {
      if (_isLoading || !_hasMore) return;

      emit(const EncryptedGalleryState.loading());
      _isLoading = true;

      final files =
          (_album as Directory).listSync().toList()..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

      if (files.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        final files =
            (_album as Directory).listSync().toList()..sort(
              (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
            );

        if (files.isEmpty) {
          _hasMore = false;
          _isLoading = false;
          _emit(emit);
          return;
        }

        final start = _currentPage * _pageSize;
        final end = (_currentPage + 1) * _pageSize;
        final pageFiles = files.sublist(
          start,
          end > files.length ? files.length : end,
        );

        if (pageFiles.isEmpty) {
          _hasMore = false;
          _isLoading = false;
          _emit(emit);
          return;
        }

        for (final fileSystem in pageFiles) {
          final fileName = fileSystem.path.split('/').last;
          final date = fileSystem.statSync().modified;
          final file = File(fileSystem.path);
          if (fileName.contains('.')) {
            _entities.add(EncryptedImage(id: fileName, file: file, date: date));
          } else {
            _entities.add(EncryptedFolder.empty(fileSystem.path));
          }
          // file.deleteSync(); // Delete original file after adding to gallery
          _emit(emit);
        }

        _currentPage++;
        _isLoading = false;
        _emit(emit);
        return;
      }

      final start = _currentPage * _pageSize;
      final end = (_currentPage + 1) * _pageSize;
      final pageFiles = files.sublist(
        start,
        end > files.length ? files.length : end,
      );

      if (pageFiles.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        _emit(emit);
        return;
      }

      for (final fileSystem in pageFiles) {
        final fileName = fileSystem.path.split('/').last;
        final date = fileSystem.statSync().modified;
        final file = File(fileSystem.path);
        if (fileName.contains('.')) {
          _entities.add(EncryptedImage(id: fileName, file: file, date: date));
        } else {
          _entities.add(EncryptedFolder.empty(fileSystem.path));
        }
        // file.deleteSync(); // Delete original file after adding to gallery
        _emit(emit);
      }

      _currentPage++;
      _isLoading = false;
      _emit(emit);
    });

    on<_DeleteImage>((event, emit) async {
      try {
        emit(const EncryptedGalleryState.loading());
        await event.image.file.delete();
        _entities.remove(event.image);
        _emit(emit);
      } catch (e) {
        log('Error deleting image: $e');
      }
    });

    on<_DecryptImage>((event, emit) async {
      emit(const EncryptedGalleryState.loading());

      final res = await _utils.decrypt(
        image: event.image,
        password: event.password,
      );

      res.fold(
        (failure) {
          emit(EncryptedGalleryState.encryptionFailure(failure: failure));
        },
        (decryptedBytes) {
          emit(EncryptedGalleryState.decrypted(data: decryptedBytes));
        },
      );
    });
    on<_DecryptFolder>((event, emit) async {
      emit(const EncryptedGalleryState.loading());

      final images = _entities.whereType<EncryptedImage>().toList();
      for (final image in images) {
        image.isDecrypting = true;
      }
      _emit(emit);

      log('Starting decryption of entire folder with ${images.length} images');
      for (final entity in images) {
        final image = entity.asImage;
        final res = await _utils.decrypt(
          image: image,
          password: event.password,
        );

        res.fold(
          (failure) {
            log('Decryption failed for image ${image.id}: ${failure.message}');
          },
          (decryptedBytes) {
            log('Decryption succeeded for image ${image.id}');
            image.isDecrypting = false;
            image.decryptedBytes = decryptedBytes;
          },
        );

        _emit(emit);
      }

      log('Decryption of entire folder completed');
    });

    on<_CreateFolder>((event, emit) async {
      emit(const EncryptedGalleryState.loading());
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
        _album = folderPath;
      } catch (e) {
        log('Error creating folder: $e');
      }

      _emit(emit);
    });
    on<_DeleteFolder>((event, emit) async {
      try {
        final dir = await encryptedFolder;
        final dirName = dir.path.split('/').last;
        if (!await dir.exists()) {
          log('Folder does not exist: $dirName');
          return;
        }

        await dir.delete(recursive: true);
        _entities.removeWhere(
          (entity) => entity.isFolder && entity.asFolder.name == dirName,
        );

        _emit(emit);
      } catch (e) {
        log('Error deleting folder: $e');
      }
    });
  }

  void _emit(Emitter<EncryptedGalleryState> emit) {
    emit(
      EncryptedGalleryState.loaded(
        images: List<EncryptedImage>.from(images),
        isLoading: _isLoading,
        hasMore: _hasMore,
      ),
    );
  }
}
