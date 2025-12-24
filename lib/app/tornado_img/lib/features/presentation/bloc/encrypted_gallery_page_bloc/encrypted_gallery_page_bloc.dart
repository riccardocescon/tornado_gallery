import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'encrypted_gallery_page_event.dart';
part 'encrypted_gallery_page_state.dart';
part 'encrypted_gallery_page_bloc.freezed.dart';

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

  // Delegate to core bloc for operations
  final encryptedGalleryBloc = getIt<EncryptedGalleryBloc>();

  // Getters
  String? get root => _root;
  List<EncryptedImage> get images =>
      _entities.whereType<EncryptedImage>().toList();
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<Directory> get encryptedFolder async {
    final baseDir = await encryptedGalleryBloc.encryptedFolder;
    if (_root != null) {
      return Directory('${baseDir.path}/$_root');
    }
    return baseDir;
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
    });

    on<_LoadNextPage>((event, emit) async {
      if (_isLoading || !_hasMore) return;

      emit(const EncrpytedGalleryPageState.loading());
      _isLoading = true;

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
      try {
        emit(const EncrpytedGalleryPageState.loading());
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
        emit(
          EncrpytedGalleryPageState.failure(
            message: 'Error deleting folder: $e',
          ),
        );
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
        _album = folderPath;
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

      // Listen to crypto bloc for results
      final subscription = encryptedGalleryBloc.stream.listen((cryptoState) {
        cryptoState.maybeMap(
          decrypted: (value) {
            emit(EncrpytedGalleryPageState.decrypted(data: value.data));
          },
          encryptionFailure: (value) {
            emit(
              EncrpytedGalleryPageState.failure(message: value.failure.message),
            );
          },
          orElse: () {},
        );
      });

      // Trigger decryption
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decrytImage(
          image: event.image,
          password: event.password,
          path: event.path,
        ),
      );

      // Cancel subscription after a timeout or success
      Timer(const Duration(seconds: 30), () => subscription.cancel());
    });

    on<_DecryptFolder>((event, emit) async {
      emit(const EncrpytedGalleryPageState.loading());
      final imagesToDecrypt = images;

      if (imagesToDecrypt.isEmpty) {
        emit(
          const EncrpytedGalleryPageState.failure(
            message: 'No images to decrypt',
          ),
        );
        return;
      }

      // Listen to crypto bloc for results
      final subscription = encryptedGalleryBloc.stream.listen((cryptoState) {
        cryptoState.maybeMap(
          decrypted: (value) {
            _emit(emit); // Update UI with progress
          },
          encryptionFailure: (value) {
            emit(
              EncrpytedGalleryPageState.failure(message: value.failure.message),
            );
          },
          orElse: () {},
        );
      });

      // Trigger folder decryption
      encryptedGalleryBloc.add(
        EncryptedGalleryEvent.decrytFolder(
          images: imagesToDecrypt,
          password: event.password,
        ),
      );

      // Cancel subscription after a timeout
      Timer(const Duration(minutes: 5), () => subscription.cancel());
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
