import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';
import 'package:image/image.dart' as img;

part 'encrypted_gallery_bloc.freezed.dart';
part 'encrypted_gallery_event.dart';
part 'encrypted_gallery_state.dart';
part 'encrypted_gallery_bloc_utils.dart';

// Top-level function for isolate decryption
typedef DecryptionTask = ({img.Image image, CryptoConfig config});

Future<CryptoResult> _decryptImageInIsolate(DecryptionTask task) async {
  return await ImageCrypto.decryptImageObject(
    image: task.image,
    config: task.config,
  );
}

class EncryptedGalleryBloc
    extends Bloc<EncryptedGalleryEvent, EncryptedGalleryState> {

  // Global state for crypto operations - this persists across page navigation
  final List<EncryptedImage> _globalImages = [];
  
  // Crypto operations
  final _EncryptedGalleryBlocUtils _utils = _EncryptedGalleryBlocUtils();
  
  // Getters for crypto operations
  List<EncryptedImage> get images => List.unmodifiable(_globalImages);
  
  // Factory method for creating images with preserved state
  List<EncryptedImage> createImagesWithPersistedState(
    List<ImageData> imageDataList,
  ) {
    return imageDataList.map((imageData) {
      // Look for existing image to preserve decrypted state
      final existingIndex = _globalImages.indexWhere(
        (img) => img.file.path == imageData.file.path,
      );

      if (existingIndex != -1) {
        // Return existing image (preserves decryptedBytes)
        return _globalImages[existingIndex];
      } else {
        // Create new image and add to global list
        final newImage = EncryptedImage(
          id: imageData.id,
          file: imageData.file,
          date: imageData.date,
        );
        _globalImages.add(newImage);
        return newImage;
      }
    }).toList();
  }

  // Check if image is already decrypted
  bool isImageDecrypted(String filePath) {
    final image =
        _globalImages.where((img) => img.file.path == filePath).firstOrNull;
    return image?.decryptedBytes != null;
  }
  
  Future<Directory> get encryptedFolder async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory('${dir.path}/encrypted');
  }

  EncryptedGalleryBloc() : super(const EncryptedGalleryState.initial()) {
    
    on<_DecryptImage>((event, emit) async {
      emit(const EncryptedGalleryState.loading());

      final res = await _utils.decrypt(
        image: event.image,
        password: event.password,
      );

      res.fold(
        (failure) {
          emit(EncryptedGalleryState.encryptionFailure(failure: failure));
        },
        (decryptedBytes) {
          // Find existing image in global list or use the provided one
          final existingIndex = _globalImages.indexWhere(
            (img) => img.file.path == event.image.file.path,
          );
          final targetImage =
              existingIndex != -1 ? _globalImages[existingIndex] : event.image;

          // Update with decrypted data
          targetImage.decryptedBytes = decryptedBytes;
          targetImage.isDecrypting = false;

          // Add to global list if not already there
          if (existingIndex == -1) {
            _globalImages.add(targetImage);
          }

          emit(EncryptedGalleryState.decrypted(data: targetImage));

          log('Decrypted and cached image: ${targetImage.file.path}');
        },
      );
    });

    on<_DecryptFolder>((event, emit) async {
      emit(const EncryptedGalleryState.loading());

      final images = event.images;
      for (final image in images) {
        image.isDecrypting = true;
      }

      log('Starting decryption of entire folder with ${images.length} images');
      for (final image in images) {
        final res = await _utils.decrypt(
          image: image,
          password: event.password,
        );

        res.fold(
          (failure) {
            log('Decryption failed for image ${image.id}: ${failure.message}');
          },
          (decryptedBytes) {
            log('Decryption succeeded for image ${image.id}');
            
            // Find existing image in global list or use the provided one
            final existingIndex = _globalImages.indexWhere(
              (img) => img.file.path == image.file.path,
            );
            final targetImage =
                existingIndex != -1 ? _globalImages[existingIndex] : image;

            // Update with decrypted data
            targetImage.decryptedBytes = decryptedBytes;
            targetImage.isDecrypting = false;

            // Add to global list if not already there
            if (existingIndex == -1) {
              _globalImages.add(targetImage);
            }

            emit(EncryptedGalleryState.decrypted(data: targetImage));

            log('Decrypted and cached image: ${targetImage.file.path}');
          },
        );
      }

      
      log('Decryption of entire folder completed');

      emit(const EncryptedGalleryState.decryptedFolderCompleted());
    });

    on<_DeleteFolderGlobal>((event, emit) async {
      try {
        final baseDir = await encryptedFolder;
        final folderToDelete = Directory('${baseDir.path}/${event.folderName}');

        if (!await folderToDelete.exists()) {
          log('Folder does not exist: ${event.folderName}');
          return;
        }

        await folderToDelete.delete(recursive: true);
        log('Deleted folder globally: ${event.folderName}');

        // Emit state to notify all pages
        emit(EncryptedGalleryState.folderDeleted(folderPath: event.folderName));
      } catch (e) {
        log('Error deleting folder globally: $e');
      }
    });
  }
  
  // Method to clear memory (for memory management if needed)
  void clearDecryptedData() {
    for (final image in _globalImages) {
      image.decryptedBytes = null;
      image.isDecrypting = false;
    }
    log('Cleared all decrypted data');
  }

  // Remove image from global list (when deleted)
  void removeImage(String filePath) {
    _globalImages.removeWhere((img) => img.file.path == filePath);
    log('Removed image from global list: $filePath');
  }
}
