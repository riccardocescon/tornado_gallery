import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

import '../../domain/entities/image_data.dart';
import '../../domain/repositories/image_processing_repository.dart';
import '../models/image_model.dart';

typedef _Task = ({Uint8List bytes, String password});

// Implementation for heavy tasks
Future<Uint8List> _encrypt(_Task task) {
  return processImage(input: task.bytes, phrase: task.password);
}

img.Image? _decodeImage((Uint8List, String) args) {
  final bytes = args.$1;
  final ext = args.$2;
  return img.decodeNamedImage('file.$ext', bytes);
}

Uint8List _encodeImage(ImageModel model) {
  return img.encodePng(model.toImg());
}

class ImageProcessingRepositoryImpl implements ImageProcessingRepository {
  @override
  Future<ImageData?> decode(File file) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final decoded = await compute(_decodeImage, (bytes, ext));
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
    return await compute(_encodeImage, model);
  }

}
