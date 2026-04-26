import 'dart:io';
import 'dart:typed_data';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';

abstract class ImageProcessingRepository {
  Future<ImageData?> decode(File file);

  Future<ImageData> encrypt(ImageData image, String password);

  Future<Uint8List?> encode(ImageData image);
}
