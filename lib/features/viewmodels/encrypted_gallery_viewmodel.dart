import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img/features/models/encrypted_image.dart';

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
  late FileSystemEntity _album;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final appDir = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appDir.path}/encrypted');

    if (!encryptedDir.existsSync()) {
      await encryptedDir.create(recursive: true);
    }

    final albums = encryptedDir.listSync().toList();

    if (albums.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _album = encryptedDir;
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

    final files =
        (_album as Directory).listSync().toList()..sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
        ); // optional sort

    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;
    final pageFiles = files.sublist(
      start,
      end > files.length ? files.length : end,
    );

    if (pageFiles.isEmpty) {
      _hasMore = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    for (final fileSystem in pageFiles) {
      final fileName = fileSystem.path.split('/').last;
      final date = fileSystem.statSync().modified;
      final file = File(fileSystem.path);
      _images.add(EncryptedImage(id: fileName, file: file, date: date));
      // file.deleteSync(); // Delete original file after adding to gallery
      notifyListeners();
    }

    _currentPage++;
    _isLoading = false;
    notifyListeners();
  }
}
