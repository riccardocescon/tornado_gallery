import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

import 'package:pointycastle/api.dart';

img.Image? decodeImage(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final ext = args['ext'] as String;

  final decoders = {
    'png': img.decodePng,
    'jpg': img.decodeJpg,
    'jpeg': img.decodeJpg,
    'webp': img.decodeWebP,
  };

  final decodeFunction = decoders[ext];
  if (decodeFunction == null) return null;

  return decodeFunction(bytes);
}

Future<img.Image> scrambleImageIsolateV2(Map<String, dynamic> args) async {
  final originalBytes = args['imageBytes'] as Uint8List;
  final width = args['width'] as int;
  final height = args['height'] as int;
  final password = args['password'] as String;
  final encrypt = args['encrypt'] as bool;

  final key = sha256.convert(utf8.encode(password)).bytes;
  final iv = Uint8List.fromList(List.generate(16, (i) => i));

  final pixels = originalBytes;

  final cipher = StreamCipher(
    'AES/CTR',
  )..init(encrypt, ParametersWithIV(KeyParameter(Uint8List.fromList(key)), iv));

  final scrambled = cipher.process(pixels);

  return img.Image.fromBytes(
    width: width,
    height: height,
    bytes: scrambled.buffer,
  );
}
