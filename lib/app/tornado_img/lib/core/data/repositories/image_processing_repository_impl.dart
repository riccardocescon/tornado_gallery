import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tornado_img_app/core/data/models/image_model.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

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
  ImageProcessingRepositoryImpl() {
    final packageVersion = sdkVersion();
    appLogger.log(
      "ImageProcessingRepositoryImpl initialized with TornadoImgCrypto version: $packageVersion",
      LogLayer.repository,
    );
  }

  @override
  Future<ImageData?> decode(File file) async {
    final bytes = await file.readAsBytes();
    final ext = FileNameUtils.extensionOf(file.path);
    return decodeBytes(bytes, extension: ext);
  }

  @override
  Future<ImageData?> decodeBytes(
    Uint8List bytes, {
    required String extension,
  }) async {
    final ext = extension.toLowerCase();
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
