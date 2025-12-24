import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';
part 'gallery_bloc_utils.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final int kPageSize = 50;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final _images = <GalleryImage>[];

  // Cache album to reuse on pagination
  late AssetPathEntity _album;

  final _GlobalBlocUtils _utils = _GlobalBlocUtils();

  GalleryBloc() : super(const GalleryState.initial()) {
    on<_Setup>((event, emit) async {
      emit(const GalleryState.loading());

      final permission = await Permission.photos.request();

      if (permission.isDenied || permission.isPermanentlyDenied) {
        emit(const GalleryState.permissionDenied());
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

      add(const GalleryEvent.loadNextPage());
    });

    on<_LoadNextPage>((event, emit) async {
      if (_isLoading || !_hasMore) return;

      emit(const GalleryState.loading());
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

        final insertIndex = _utils.findInsertIndexDescending(
          _images,
          newImage.date,
        );
        _images.insert(insertIndex, newImage);
      }

      _currentPage++;
      _isLoading = false;
      _emit(emit);
    });

    on<_PickFiles>((event, emit) async {
      final hasPermissions = await _utils.requestPermission();
      if (!hasPermissions) {
        log('Permission denied');
        return;
      }

      emit(const GalleryState.loading());

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
            final savedAsset = await _utils.findSavedImageByName(name);
            if (savedAsset != null) {
              final savedFile = await savedAsset.file;
              if (savedFile != null) {
                final newImage = GalleryImage(
                  id: savedAsset.id,
                  file: savedFile,
                  date: savedAsset.createDateTime,
                );
                final insertIndex = _utils.findInsertIndexDescending(
                  _images,
                  newImage.date,
                );
                _images.insert(insertIndex, newImage);
              }
            }

            _emit(emit);
          } else {
            log('Failed to save image: ${result.errorMessage}');
          }
        }

        _emit(emit);
      }
    });

    on<_DeleteImage>((event, emit) async {
      emit(const GalleryState.loading());
      final deletedIds = await PhotoManager.editor.deleteWithIds([
        event.image.id,
      ]);
      for (final id in deletedIds) {
        _images.removeWhere((img) => img.id == id);
      }
      _emit(emit);
    });

    on<_EncryptImage>((event, emit) async {
      String ext = event.image.file.path.split('.').last.toLowerCase();
      final fileBytes = await event.image.file.readAsBytes();

      final decodedImage = ImageCrypto.decodeImageFromBytes(
        bytes: fileBytes,
        extension: ext,
      );

      if (decodedImage == null) {
        log('Failed to decode image or unsupported format: $ext');
        emit(
          GalleryState.encryptionFailure(
            failure: EncryptionFailure.unsupportedExtension(ext),
          ),
        );
        return;
      }

      final config = CryptoConfig(
        password: event.password,
        numChannels: ext == 'png' ? 4 : null,
      );

      final initEncryptTime = DateTime.now();
      final result = await ImageCrypto.encryptImageObject(
        image: decodedImage,
        config: config,
      );
      final encryptDuration = DateTime.now().difference(initEncryptTime);
      log('Image encrypted in ${encryptDuration.inMilliseconds} ms');

      if (result case CryptoFailure failure) {
        log('Encryption failed: ${failure.message}');
        emit(
          GalleryState.encryptionFailure(
            failure: EncryptionFailure.encryptionError(failure.message),
          ),
        );
        return;
      }

      if (result case CryptoSuccess success) {
        // Force save as PNG after encryption
        final encodedBytes = ImageCrypto.encodeImageToBytes(
          image: success.image,
          extension: 'png',
        );

        if (encodedBytes == null) {
          emit(
            GalleryState.encryptionFailure(
              failure: EncryptionFailure.encryptionError(
                'Failed to encode encrypted image',
              ),
            ),
          );
          return;
        }

        // store the encrypted image into appDocumentsFolder
        final docDir = await getApplicationDocumentsDirectory();

        final destFolder = event.path ?? '${docDir.path}/encrypted';

        final encryptedFile = File('$destFolder/${event.image.id}.$ext.png');
        await encryptedFile.create(recursive: true);

        encryptedFile.writeAsBytesSync(encodedBytes);
        log('Image saved: ${encryptedFile.path}');

        emit(const GalleryState.encrypted());
        return;
      }

      emit(
        GalleryState.encryptionFailure(
          failure: EncryptionFailure.encryptionError(
            'Unknown encryption error',
          ),
        ),
      );
    });
  }

  void _emit(Emitter<GalleryState> emit) {
    emit(
      GalleryState.loaded(
        images: List<GalleryImage>.from(_images),
        isLoading: _isLoading,
        hasMore: _hasMore,
      ),
    );
  }
}
