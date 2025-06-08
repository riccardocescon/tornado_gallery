import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img/core/image/image_modeling.dart';
import 'package:tornado_img/core/managers/stream_manager.dart';
import 'package:tornado_img/features/models/encrypted_image.dart';

class EncryptedGalleryViewModel extends ChangeNotifier {
  final int _pageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _images = <EncryptedImage>[];

  StreamSubscription<FileSystemEvent>? _streamSubscription;

  List<EncryptedImage> get images => _images;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Cache album to reuse on pagination
  late FileSystemEntity _album;

  EncryptedGalleryViewModel();

  EncryptedGalleryViewModel._(
    int currentPage,
    bool isLoading,
    bool hasMore,
    List<EncryptedImage> images,
    FileSystemEntity album,
  ) {
    _currentPage = currentPage;
    _isLoading = isLoading;
    _hasMore = hasMore;
    _images.addAll(images);
    _album = album;
  }

  EncryptedGalleryViewModel copyWith({
    int? pageSize,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    List<EncryptedImage>? images,
    FileSystemEntity? album,
  }) {
    return EncryptedGalleryViewModel._(
      currentPage ?? _currentPage,
      isLoading ?? _isLoading,
      hasMore ?? _hasMore,
      images ?? List<EncryptedImage>.from(_images),
      album ?? _album,
    );
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final appDir = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appDir.path}/encrypted');

    if (!encryptedDir.existsSync()) {
      await encryptedDir.create(recursive: true);
    }

    final albums = encryptedDir.listSync().toList();

    _streamSubscription?.cancel();
    _streamSubscription = encryptedDir.watch().listen((stream) {
      if (stream is FileSystemCreateEvent || stream is FileSystemModifyEvent) {
        final fileName = stream.path.split('/').last;
        final date = DateTime.now();
        final file = File(stream.path);
        final imageIndex = _images.indexWhere((image) => image.id == fileName);
        if (imageIndex != -1) {
          _images[imageIndex] = EncryptedImage(
            id: fileName,
            file: file,
            date: date,
          );
        } else {
          _images.add(EncryptedImage(id: fileName, file: file, date: date));
        }
        notifyListeners();
      } else if (stream is FileSystemDeleteEvent) {
        _images.removeWhere((image) => image.file.path == stream.path);
        notifyListeners();
      }
    });

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
        );

    if (files.isEmpty) {
      _hasMore = false;
      _isLoading = false;
      notifyListeners();
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

  Future<void> deleteImage(EncryptedImage image) async {
    try {
      await image.file.delete();
      _images.remove(image);
      notifyListeners();
    } catch (e) {
      log('Error deleting image: $e');
    }
  }

  Future<Uint8List?> decryptImage({
    required EncryptedImage image,
    required String password,
  }) async {
    final decoders = {
      'png': img.decodePng,
      'jpg': img.decodeJpg,
      'jpeg': img.decodeJpg,
    };
    final ext = image.file.path.split('.').last.toLowerCase();
    final decodeFunction = decoders[ext];
    if (decodeFunction == null) {
      log('Unsupported image format: $ext');
      return null;
    }

    final fileBytes = await image.file.readAsBytes();
    final initDecodeTime = DateTime.now();
    final decodedImage = await compute(decodeImage, {
      'bytes': fileBytes,
      'ext': ext,
    });
    final decodeDuration = DateTime.now().difference(initDecodeTime);
    log('Image decoded in ${decodeDuration.inMilliseconds} ms');
    if (decodedImage == null) {
      log('Failed to decode image');
      return null;
    }

    final imageBytes = decodedImage.toUint8List();
    final initScrambleTime = DateTime.now();
    final encryptedImage = await compute(scrambleImageIsolateV2, {
      'imageBytes': imageBytes,
      'width': decodedImage.width,
      'height': decodedImage.height,
      'password': password,
    });
    final scrambleDuration = DateTime.now().difference(initScrambleTime);
    log('Image scrambled in ${scrambleDuration.inMilliseconds} ms');

    Uint8List encodedBytes;

    switch (ext) {
      case 'png':
        encodedBytes = Uint8List.fromList(img.encodePng(encryptedImage));
        break;
      case 'jpg':
      case 'jpeg':
        encodedBytes = Uint8List.fromList(img.encodeJpg(encryptedImage));
        break;
      default:
        return null;
    }

    return encodedBytes;
  }
}
