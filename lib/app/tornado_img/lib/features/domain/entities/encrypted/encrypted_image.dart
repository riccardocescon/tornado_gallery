import 'dart:io';
import 'dart:typed_data';

class EncryptedImage {
  final String path;
  final DateTime date;
  Uint8List? bytes;

  bool get isDecrypted => bytes != null;

  File get file => File(path);

  EncryptedImage({
    required this.path, required this.date, this.bytes,
  });

  String get name => path.split('/').last;
}
