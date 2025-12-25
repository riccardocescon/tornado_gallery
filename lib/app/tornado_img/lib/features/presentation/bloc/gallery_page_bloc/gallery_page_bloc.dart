import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/injection_container.dart';

part 'gallery_page_bloc.freezed.dart';
part 'gallery_page_event.dart';
part 'gallery_page_state.dart';

class GalleryPageBloc extends Bloc<GalleryPageEvent, GalleryPageState> {
  
  // Page state management
  final int kPageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<GalleryImage> _images = [];

  // Mantieni posizione scroll tra navigazioni
  double? savedScrollPosition;

  // Cache album to reuse on pagination
  late AssetPathEntity _album;

  // Crypto operations delegate
  final galleryBloc = getIt<GalleryBloc>();
  
  // Getters
  List<GalleryImage> get images => List<GalleryImage>.from(_images);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  GalleryPageBloc() : super(const GalleryPageState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const GalleryPageState.loading());

      final permission = await Permission.photos.request();

      if (permission.isDenied || permission.isPermanentlyDenied) {
        emit(
          const GalleryPageState.failure(
            message: 'Permission denied to access gallery.',
          ),
        );
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        _isLoading = false;
        _hasMore = false;
        _emit(emit);
        return;
      }

      _album = albums.first;
      _images.clear();
      _currentPage = 0;
      _hasMore = true;

      add(const GalleryPageEvent.loadNextPage());
    });

    on<_LoadNextPage>((event, emit) async {
      if (_isLoading || !_hasMore) return;

      emit(const GalleryPageState.loading());
      _isLoading = true;

      final assetList = await _album.getAssetListPaged(
        page: _currentPage,
        size: kPageSize,
      );

      if (assetList.isEmpty) {
        _hasMore = false;
        _isLoading = false;
        _emit(emit);
        return;
      }

      for (final asset in assetList) {
        final file = await asset.file;
        if (file == null) continue;

        final newImage = GalleryImage(
          id: asset.id,
          file: file,
          date: asset.createDateTime,
        );

        final insertIndex = _findInsertIndexAscending(_images, newImage.date);
        _images.insert(insertIndex, newImage);
      }

      _currentPage++;
      _isLoading = false;
      _emit(emit);
    });

    on<_PickFiles>((event, emit) async {
      emit(const GalleryPageState.loading());

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
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
            final savedAsset = await _findSavedImageByName(name);
            if (savedAsset != null) {
              final savedFile = await savedAsset.file;
              if (savedFile != null) {
                final newImage = GalleryImage(
                  id: savedAsset.id,
                  file: savedFile,
                  date: savedAsset.createDateTime,
                );
                final insertIndex = _findInsertIndexAscending(
                  _images,
                  newImage.date,
                );
                _images.insert(insertIndex, newImage);
              }
            }
          } else {
            log('Failed to save image: ${saveResult.errorMessage}');
          }
        }
        _emit(emit);
      }
    });

    on<_EncryptImage>((event, emit) async {
      emit(const GalleryPageState.loading());

      // Trigger encryption
      galleryBloc.add(
        GalleryEvent.encryptImage(
          image: event.image,
          password: event.password,
          path: event.path,
        ),
      );

      await for (final cryptoState in galleryBloc.stream) {
        final completed = cryptoState.maybeMap(
          encrypted: (value) {
            emit(const GalleryPageState.encrypted());
            return true;
          },
          encryptionFailure: (value) {
            emit(GalleryPageState.failure(message: value.failure.message));
            return true;
          },
          orElse: () => false,
        );

        if (completed) break;
      }
    });

    on<_DeleteImage>((event, emit) async {
      emit(const GalleryPageState.loading());
      final deletedIds = await PhotoManager.editor.deleteWithIds([
        event.image.id,
      ]);
      for (final id in deletedIds) {
        _images.removeWhere((img) => img.id == id);
      }
      _emit(emit);
    });

    on<_SaveScrollPosition>(
      (event, emit) => savedScrollPosition = event.position,
    );
  }

  // Helper methods
  int _findInsertIndexAscending(List<GalleryImage> images, DateTime date) {
    int left = 0;
    int right = images.length;

    while (left < right) {
      int mid = (left + right) ~/ 2;
      if (images[mid].date.isBefore(date)) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }

    return left;
  }

  Future<AssetEntity?> _findSavedImageByName(String name) async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) return null;

      final assetsCount = await albums.first.assetCountAsync;
      const int searchPageSize = 100;

      log(
        'Searching for "$name" in $assetsCount total assets (starting from most recent)',
      );

      // Calculate total pages
      final totalPages = (assetsCount / searchPageSize).ceil();

      // Start from the LAST page (most recent) and work backwards
      for (int page = totalPages - 1; page >= 0; page--) {
        final recentAssets = await albums.first.getAssetListPaged(
          page: page,
          size: searchPageSize,
        );

        // Early termination if no more assets
        if (recentAssets.isEmpty) {
          log('No more assets found at page $page, stopping search');
          continue;
        }

        // Search within this page (reverse order to get most recent first)
        for (int i = recentAssets.length - 1; i >= 0; i--) {
          try {
            final asset = recentAssets[i];
            final title = await asset.titleAsync;
            if (title == name) {
              log(
                'Found matching asset: $title at page $page (${totalPages - page} pages from end)',
              );
              return asset;
            }
          } catch (e) {
            // Continue if single asset fails
            log('Error getting title for asset: $e');
          }
        }
        
        log(
          'Searched page $page (${recentAssets.length} assets) - ${totalPages - page} pages from end',
        );

        // Early exit after searching reasonable number of recent pages
        if ((totalPages - page) > 10) {
          log(
            'Searched 10 most recent pages without success, stopping for performance',
          );
          break;
        }
      }

      log('Image "$name" not found in recent assets');
      return null;
    } catch (e) {
      log('Error in _findSavedImageByName: $e');
      return null;
    }
  }

  void _emit(Emitter<GalleryPageState> emit) {
    emit(
      GalleryPageState.loaded(
        images: List<GalleryImage>.from(_images),
        isLoading: _isLoading,
        hasMore: _hasMore,
        savedScrollPosition: savedScrollPosition ?? 0.0,
      ),
    );
  }
}
