import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
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

  // Global state for crypto operations
  final List<EncryptedImage> _globalImages = [];
  
  // Crypto operations
  final _EncryptedGalleryBlocUtils _utils = _EncryptedGalleryBlocUtils();
  
  // Getters for crypto operations
  List<EncryptedImage> get images => List.unmodifiable(_globalImages);
  
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
          emit(EncryptedGalleryState.decrypted(data: decryptedBytes));
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
            image.isDecrypting = false;
            image.decryptedBytes = decryptedBytes;
          },
        );
      }

      emit(
        EncryptedGalleryState.decrypted(data: Uint8List(0)),
      ); // Signal completion
      log('Decryption of entire folder completed');
    });
  }
}
