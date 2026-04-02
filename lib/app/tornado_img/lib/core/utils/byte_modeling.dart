import 'dart:typed_data';

class ByteModeling {
  static String generateHash(Uint8List bytes) {
    int hash = 5381;
    for (int i = 0; i < bytes.length; i++) {
      hash = ((hash << 5) + hash) + bytes[i];
    }
    return hash.toString();
  }
}
