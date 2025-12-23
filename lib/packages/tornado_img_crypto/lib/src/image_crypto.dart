import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:pointycastle/api.dart';

import 'crypto_config.dart';
import 'crypto_result.dart';

/// Main class for image encryption and decryption operations
class ImageCrypto {
  /// Encrypts an image using AES-CTR cipher
  ///
  /// [imageBytes] - Raw bytes of the image
  /// [width] - Image width
  /// [height] - Image height
  /// [config] - Encryption configuration including password and options
  ///
  /// Returns [CryptoResult] containing either success or failure
  static Future<CryptoResult> encryptImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required CryptoConfig config,
  }) async {
    try {
      final result = await _processImage(
        imageBytes: imageBytes,
        width: width,
        height: height,
        config: config,
        encrypt: true,
      );
      return result;
    } catch (e) {
      return CryptoFailure(
        message: 'Encryption failed',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Decrypts an image using AES-CTR cipher
  ///
  /// [imageBytes] - Raw bytes of the encrypted image
  /// [width] - Image width
  /// [height] - Image height
  /// [config] - Decryption configuration including password and options
  ///
  /// Returns [CryptoResult] containing either success or failure
  static Future<CryptoResult> decryptImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required CryptoConfig config,
  }) async {
    try {
      final result = await _processImage(
        imageBytes: imageBytes,
        width: width,
        height: height,
        config: config,
        encrypt: false,
      );
      return result;
    } catch (e) {
      return CryptoFailure(
        message: 'Decryption failed',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// Convenience method to encrypt an img.Image directly
  static Future<CryptoResult> encryptImageObject({
    required img.Image image,
    required CryptoConfig config,
  }) async {
    return encryptImage(
      imageBytes: image.toUint8List(),
      width: image.width,
      height: image.height,
      config: config,
    );
  }

  /// Convenience method to decrypt to an img.Image directly
  static Future<CryptoResult> decryptImageObject({
    required img.Image image,
    required CryptoConfig config,
  }) async {
    return decryptImage(
      imageBytes: image.toUint8List(),
      width: image.width,
      height: image.height,
      config: config,
    );
  }

  /// Decodes image from bytes with format detection
  ///
  /// [bytes] - Raw image file bytes
  /// [extension] - File extension (png, jpg, jpeg, webp)
  ///
  /// Returns decoded img.Image or null if decoding fails
  static img.Image? decodeImageFromBytes({
    required Uint8List bytes,
    required String extension,
  }) {
    final ext = extension.toLowerCase();

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

  /// Encodes image to bytes in the specified format
  ///
  /// [image] - The img.Image to encode
  /// [extension] - Target format (png, jpg, jpeg)
  ///
  /// Returns encoded bytes or null if encoding fails
  static Uint8List? encodeImageToBytes({
    required img.Image image,
    required String extension,
  }) {
    final ext = extension.toLowerCase();

    try {
      switch (ext) {
        case 'png':
          return Uint8List.fromList(img.encodePng(image));
        case 'jpg':
        case 'jpeg':
          return Uint8List.fromList(img.encodeJpg(image));
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Internal method that performs the actual encryption/decryption
  static Future<CryptoResult> _processImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required CryptoConfig config,
    required bool encrypt,
  }) async {
    try {
      // Generate key from password using SHA-256
      final key = sha256.convert(utf8.encode(config.password)).bytes;

      // Create cipher with AES-CTR mode
      final cipher = StreamCipher('AES/CTR')..init(
        encrypt,
        ParametersWithIV(
          KeyParameter(Uint8List.fromList(key)),
          config.effectiveIV,
        ),
      );

      // Process the image bytes
      final processedBytes = cipher.process(imageBytes);

      // Create processed image
      final processedImage = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: processedBytes.buffer,
        numChannels: config.numChannels,
      );

      return CryptoSuccess(image: processedImage, bytes: processedBytes);
    } catch (e) {
      return CryptoFailure(
        message: 'Processing failed: ${e.toString()}',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
