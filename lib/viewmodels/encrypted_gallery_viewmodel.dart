import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img/models/encrypted_image.dart';

class EncryptedGalleryViewModel extends ChangeNotifier {
  final int _pageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _images = <EncryptedImage>[];

  List<EncryptedImage> get images => _images;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Cache album to reuse on pagination
  late AssetPathEntity _album;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final appDir = await getApplicationDocumentsDirectory();

    if (!appDir.existsSync()) {
      await appDir.create(recursive: true);
    }

    final albums = appDir.listSync().whereType<AssetPathEntity>().toList();

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
    if (_isLoading || !_hasMore) return;
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
        _images.add(EncryptedImage(file: file, date: asset.createDateTime));
        notifyListeners();
      }
    }

    _currentPage++;
    _isLoading = false;
    notifyListeners();
  }
}
