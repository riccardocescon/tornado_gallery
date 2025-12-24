import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';
import 'package:image/image.dart' as img;

part 'gallery_bloc.freezed.dart';
part 'gallery_event.dart';
part 'gallery_state.dart';

// Top-level function for isolate encryption
typedef EncryptionTask = ({img.Image image, CryptoConfig config});

Future<CryptoResult> _encryptImageInIsolate(EncryptionTask task) async {
  return await ImageCrypto.encryptImageObject(
    image: task.image,
    config: task.config,
  );
}

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {

  GalleryBloc() : super(const GalleryState.initial()) {
    on<_EncryptImage>((event, emit) async {
      emit(const GalleryState.loading());
      
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
      final result = await compute(_encryptImageInIsolate, (
        image: decodedImage,
        config: config,
      ));
      final encryptDuration = DateTime.now().difference(initEncryptTime);
      log('Image encrypted in ${encryptDuration.inMilliseconds} ms (isolate)');

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
            'Unknown error during encryption',
          ),
        ),
      );
    });
  }
}
