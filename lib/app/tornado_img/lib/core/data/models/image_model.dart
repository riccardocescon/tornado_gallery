import 'package:image/image.dart' as img;
import '../../domain/entities/image_data.dart';

class ImageModel extends ImageData {
  const ImageModel({
    required super.width,
    required super.height,
    required super.channels,
    required super.bytes,
  });

  factory ImageModel.fromImg(img.Image image) {
    return ImageModel(
      width: image.width,
      height: image.height,
      channels: image.numChannels,
      bytes: image.getBytes(),
    );
  }

  img.Image toImg() {
    return img.Image.fromBytes(
      width: width,
      height: height,
      bytes: bytes.buffer,
      numChannels: channels,
    );
  }
}
