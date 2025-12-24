import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

class EncryptedGalleryViewModel extends ChangeNotifier {
  String? root;

  final int _pageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _entities = <EncryptedEntity>[];

  StreamSubscription<FileSystemEvent>? _streamSubscription;

  List<EncryptedImage> get images =>
      List<EncryptedImage>.from(_entities.whereType<EncryptedImage>());
  List<EncryptedEntity> get entities => _entities.toList();
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

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
  Future<void> dispose() async {
    await _streamSubscription?.cancel();
    super.dispose();
  }

  EncryptedGalleryViewModel({required this.root});

  EncryptedGalleryViewModel._(
    int currentPage,
    bool isLoading,
    bool hasMore,
    List<EncryptedImage> images,
    FileSystemEntity album,
    this.root,
  ) {
    _currentPage = currentPage;
    _isLoading = isLoading;
    _hasMore = hasMore;
    _entities.addAll(images);
    _album = album;
  }

  EncryptedGalleryViewModel copyWith({
    int? pageSize,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    List<EncryptedImage>? images,
    FileSystemEntity? album,
    String? root,
  }) {
    return EncryptedGalleryViewModel._(
      currentPage ?? _currentPage,
      isLoading ?? _isLoading,
      hasMore ?? _hasMore,
      images ?? List<EncryptedImage>.from(_entities),
      album ?? _album,
      root ?? this.root,
    );
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final encryptedDir = await encryptedFolder;

    final albums = encryptedDir.listSync().toList();

    _streamSubscription?.cancel();
    _streamSubscription = encryptedDir.watch().listen((stream) {
      if (stream is FileSystemCreateEvent || stream is FileSystemModifyEvent) {
        log('File system event: ${stream.runtimeType} - ${stream.path}');
        final fileName = stream.path.split('/').last;
        final date = DateTime.now();
        final isFile = fileName.contains('.');
        if (isFile) {
          final file = File(stream.path);
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
            _entities.add(EncryptedImage(id: fileName, file: file, date: date));
          }
        } else {
          final dir = Directory(stream.path);
          final folderIndex = _entities.indexWhere(
            (image) => image.tryFolder?.name == dir.path.split('/').last,
          );
          if (folderIndex != -1) {
            _entities[folderIndex] = EncryptedFolder.empty(dir.path);
          } else {
            _entities.add(EncryptedFolder.empty(dir.path));
          }
        }

        notifyListeners();
      } else if (stream is FileSystemDeleteEvent) {
        _entities.removeWhere(
          (image) =>
              (image.isImage && image.asImage.file.path == stream.path) ||
              (image.isFolder &&
                  image.asFolder.name == stream.path.split('/').last),
        );
        notifyListeners();
      }
    });

    if (albums.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _album = encryptedDir;
    _entities.clear();
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
      if (fileName.contains('.')) {
        _entities.add(EncryptedImage(id: fileName, file: file, date: date));
      } else {
        _entities.add(EncryptedFolder.empty(fileSystem.path));
      }
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
      _entities.remove(image);
      notifyListeners();
    } catch (e) {
      log('Error deleting image: $e');
    }
  }

  Future<Uint8List?> decryptImage({
    required EncryptedImage image,
    required String password,
  }) async {
    final ext = image.file.path.split('.').last.toLowerCase();
    final fileBytes = await image.file.readAsBytes();

    final decodedImage = ImageCrypto.decodeImageFromBytes(
      bytes: fileBytes,
      extension: ext,
    );

    if (decodedImage == null) {
      log('Failed to decode image or unsupported format: $ext');
      return null;
    }

    final fileParts = image.file.path.split('.');
    final originalExt = fileParts[fileParts.length - 2].toLowerCase();

    final config = CryptoConfig(
      password: password,
      numChannels: originalExt == 'png' ? 4 : null,
    );

    final initDecryptTime = DateTime.now();
    final result = await ImageCrypto.decryptImageObject(
      image: decodedImage,
      config: config,
    );
    final decryptDuration = DateTime.now().difference(initDecryptTime);
    log('Image decrypted in ${decryptDuration.inMilliseconds} ms');

    if (result case CryptoSuccess success) {
      return ImageCrypto.encodeImageToBytes(
        image: success.image,
        extension: ext,
      );
    } else if (result case CryptoFailure failure) {
      log('Decryption failed: ${failure.message}');
      return null;
    }

    return null;
  }

  void decryptEntireFolder({required String password}) async {
    final images = _entities.whereType<EncryptedImage>().toList();
    for (final image in images) {
      image.isDecrypting = true;
    }
    notifyListeners();

    log('Starting decryption of entire folder with ${images.length} images');
    for (final entity in images) {
      final image = entity.asImage;
      final decryptedBytes = await decryptImage(
        image: image,
        password: password,
      );

      image.isDecrypting = false;
      image.decryptedBytes = decryptedBytes;

      notifyListeners();
    }

    log('Decryption of entire folder completed');
  }

  Future<void> createFolder(String name) async {
    final encryptedDir = await encryptedFolder;
    Directory folderPath = Directory('${encryptedDir.path}/$name');

    if (await folderPath.exists()) {
      log('Folder already exists: $name');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      folderPath = Directory('${encryptedDir.path}/$name-$timestamp');
    }

    try {
      await folderPath.create(recursive: true);
      _album = folderPath;
      notifyListeners();
    } catch (e) {
      log('Error creating folder: $e');
    }
  }

  static Future<List<String>> getFolderPaths() async {
    // Get the application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    String path = '${appDir.path}/encrypted';
    final encryptedDir = Directory(path);
    if (!encryptedDir.existsSync()) {
      await encryptedDir.create(recursive: true);
    }

    final folders =
        encryptedDir.listSync(recursive: true).whereType<Directory>();
    return folders.map((dir) => dir.path).toList();
  }

  Future<void> deleteFolder() async {
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
      notifyListeners();
    } catch (e) {
      log('Error deleting folder: $e');
    }
  }
}
