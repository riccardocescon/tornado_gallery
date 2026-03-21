import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

import '../../domain/entities/image_data.dart';
import '../../domain/repositories/image_processing_repository.dart';
import '../models/image_model.dart';

typedef _Task = ({Uint8List bytes, String password});

Future<Uint8List> _encrypt(_Task task) {
  return processImage(input: task.bytes, phrase: task.password);
}

class ImageProcessingRepositoryImpl implements ImageProcessingRepository {
  @override
  Future<ImageData?> decode(File file) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();

    final decoded = img.decodeNamedImage('file.$ext', bytes);

    if (decoded == null) return null;

    return ImageModel.fromImg(decoded);
  }

  @override
  Future<ImageData> encrypt(ImageData image, String password) async {
    final encryptedBytes = await compute(_encrypt, (
      bytes: image.bytes,
      password: password,
    ));

    return ImageModel(
      width: image.width,
      height: image.height,
      channels: image.channels,
      bytes: encryptedBytes,
    );
  }

  @override
  Future<Uint8List?> encode(ImageData image) async {
    final model = image as ImageModel;

    return img.encodePng(model.toImg());
  }
}
