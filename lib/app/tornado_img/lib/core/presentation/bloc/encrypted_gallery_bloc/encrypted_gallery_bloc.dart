import 'dart:async';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tornado_img_app/core/domain/repositories/encrypted_gallery_repository.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

part 'encrypted_gallery_event.dart';
part 'encrypted_gallery_state.dart';
part 'encrypted_gallery_bloc.freezed.dart';

class EncryptedGalleryBloc
    extends Bloc<EncryptedGalleryEvent, EncryptedGalleryState> {
  final EncryptedGalleryRepository repository;
  final List<EncryptedImage> _globalImages = [];

  
  List<EncryptedImage> get images => List.unmodifiable(_globalImages);

  EncryptedImage _cacheDecryptedImage(
    EncryptedImage image,
    Uint8List decryptedBytes,
  ) {
    final idx = _globalImages.indexWhere((e) => e.file.path == image.file.path);
    final target = idx != -1 ? _globalImages[idx] : image;
    target.decryptedBytes = decryptedBytes;
    target.isDecrypting = false;
    if (idx == -1) _globalImages.add(target);
    return target;
  }

  EncryptedGalleryBloc(this.repository)
    : super(const EncryptedGalleryState.initial()) {
    on<_DecryptImage>(_onDecryptImage);
    on<_DecryptFolder>(_onDecryptFolder);
    on<_DeleteFolderGlobal>(_onDeleteFolderGlobal);
  }

  Future<void> _onDecryptImage(
    _DecryptImage event,
    Emitter<EncryptedGalleryState> emit,
  ) async {
    emit(const EncryptedGalleryState.loading());

    final res = await repository.decryptImage(
      image: event.image,
      password: event.password,
    );

    res.fold(
      (failure) =>
          emit(EncryptedGalleryState.encryptionFailure(failure: failure)),
      (decryptedBytes) {
        final target = _cacheDecryptedImage(event.image, decryptedBytes);
        emit(EncryptedGalleryState.decrypted(data: target));
      },
    );
  }

  Future<void> _onDecryptFolder(
    _DecryptFolder event,
    Emitter<EncryptedGalleryState> emit,
  ) async {
    emit(const EncryptedGalleryState.loading());

    for (final image in event.images) {
      image.isDecrypting = true;
    }

    final res = await repository.decryptFolder(
      images: event.images,
      password: event.password,
    );

    res.fold(
      (failure) =>
          emit(EncryptedGalleryState.encryptionFailure(failure: failure)),
      (_) => emit(const EncryptedGalleryState.decryptedFolderCompleted()),
    );
  }

  Future<void> _onDeleteFolderGlobal(
    _DeleteFolderGlobal event,
    Emitter<EncryptedGalleryState> emit,
  ) async {
    emit(const EncryptedGalleryState.loading());

    final res = await repository.deleteFolder(event.folderName);
    res.fold(
      (failure) =>
          emit(EncryptedGalleryState.encryptionFailure(failure: failure)),
      (_) => emit(
        EncryptedGalleryState.folderDeleted(folderPath: event.folderName),
      ),
    );
  }

  void clearDecryptedData() {
    for (final image in _globalImages) {
      image.decryptedBytes = null;
      image.isDecrypting = false;
    }
  }

  void removeImage(String filePath) {
    _globalImages.removeWhere((img) => img.file.path == filePath);
  }
}
