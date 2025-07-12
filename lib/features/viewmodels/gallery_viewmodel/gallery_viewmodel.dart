import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tornado_img/core/image/image_modeling.dart';
import 'package:tornado_img/features/models/gallery_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/pointycastle.dart';

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
        final newImage = GalleryImage(
          id: asset.id,
          file: file,
          date: asset.createDateTime,
        );

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
      log('Permission denied');
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
                id: savedAsset.id,
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
          log('Failed to save image: ${result.errorMessage}');
        }
      }
      notifyListeners();
    }
  }

  Future<void> deleteImage(GalleryImage image) async {
    final deletedIds = await PhotoManager.editor.deleteWithIds([image.id]);
    for (final id in deletedIds) {
      _images.removeWhere((img) => img.id == id);
    }
    notifyListeners();
  }

  Future<String?> encryptImage({
    required GalleryImage image,
    required String password,
    required String? path,
  }) async {
    String ext = image.file.path.split('.').last.toLowerCase();
    final decodeFunction = await compute(decodeImage, {
      'bytes': await image.file.readAsBytes(),
      'ext': ext,
    });
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
      return 'Failed to decode image';
    }

    final imageBytes = decodedImage.toUint8List();
    final initScrambleTime = DateTime.now();
    final encryptedImage = await compute(scrambleImageIsolateV2, {
      'imageBytes': imageBytes,
      'width': decodedImage.width,
      'height': decodedImage.height,
      'password': password,
      'encrypt': true,
    });
    final scrambleDuration = DateTime.now().difference(initScrambleTime);
    log('Image scrambled in ${scrambleDuration.inMilliseconds} ms');

    // Enforce save as PNG after encryption
    ext = 'png';
    Uint8List encodedBytes = Uint8List.fromList(img.encodePng(encryptedImage));

    // store the encrypted image into appDocumentsFOlder
    final docDir = await getApplicationDocumentsDirectory();

    final destFolder = path ?? '${docDir.path}/encrypted';

    final encryptedFile = File('$destFolder/${image.id}.$ext');
    await encryptedFile.create(recursive: true);

    encryptedFile.writeAsBytesSync(encodedBytes);
    log('Image saved: ${encryptedFile.path}');
    return null;
  }
}
