import 'dart:typed_data';

class ImageData {
  final int width;
  final int height;
  final int channels;
  final Uint8List bytes;

  const ImageData({
    required this.width,
    required this.height,
    required this.channels,
    required this.bytes,
  });
}
