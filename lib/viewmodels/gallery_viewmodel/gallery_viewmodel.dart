import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tornado_img/models/gallery_image.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gallery_viewmodel_utils.dart';

class GalleryViewModel extends ChangeNotifier {
  final int _pageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _images = <GalleryImage>[];

  List<GalleryImage> get images => _images;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Cache album to reuse on pagination
  late AssetPathEntity _album;

  GalleryViewModel();

  GalleryViewModel._(
    int currentPage,
    bool isLoading,
    bool hasMore,
    List<GalleryImage> images,
    AssetPathEntity album,
  ) {
    _currentPage = currentPage;
    _isLoading = isLoading;
    _hasMore = hasMore;
    _images.addAll(images);
    _album = album;
  }

  GalleryViewModel copyWith({
    int? pageSize,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    List<GalleryImage>? images,
    AssetPathEntity? album,
  }) {
    return GalleryViewModel._(
      currentPage ?? _currentPage,
      isLoading ?? _isLoading,
      hasMore ?? _hasMore,
      images ?? List<GalleryImage>.from(_images),
      album ?? _album,
    );
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final permission = await Permission.photos.request();

    if (permission.isDenied || permission.isPermanentlyDenied) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _album = albums.first;
    _images.clear();
    _currentPage = 0;
    _hasMore = true;

    await _loadPage();
  }

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) {
      notifyListeners();
      return;
    }
    await _loadPage();
  }

  Future<void> _loadPage() async {
    _isLoading = true;
    notifyListeners();

    final assetList = await _album.getAssetListPaged(
      page: _currentPage,
      size: _pageSize,
    );

    if (assetList.isEmpty) {
      _hasMore = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    for (final asset in assetList) {
      final file = await asset.file;
      if (file != null) {
        final newImage = GalleryImage(file: file, date: asset.createDateTime);

        final insertIndex = _findInsertIndexDescending(images, newImage.date);
        _images.insert(insertIndex, newImage);

        notifyListeners(); // optionally debounce or batch this
      }
    }

    _currentPage++;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickFiles() async {
    final hasPermissions = await _requestPermission();
    if (!hasPermissions) {
      print('Permission denied');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      for (final file in result.files) {
        final bytes = file.bytes!;
        final name = file.name;

        final result = await SaverGallery.saveImage(
          bytes,
          quality: 100,
          fileName: name,
          skipIfExists: false,
        );

        if (result.isSuccess) {
          final savedAsset = await _findSavedImageByName(name);
          if (savedAsset != null) {
            final savedFile = await savedAsset.file;
            if (savedFile != null) {
              final newImage = GalleryImage(
                file: savedFile,
                date: savedAsset.createDateTime,
              );
              final insertIndex = _findInsertIndexDescending(
                images,
                newImage.date,
              );
              _images.insert(insertIndex, newImage);
            }
          }
          notifyListeners();
        } else {
          print('Failed to save image: ${result.errorMessage}');
        }
      }
      notifyListeners();
    }
  }
}
