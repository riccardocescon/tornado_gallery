import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Result of a crypto operation (encryption or decryption)
sealed class CryptoResult {
  const CryptoResult();
}

/// Successful result containing the processed image
class CryptoSuccess extends CryptoResult {
  /// The processed image
  final img.Image image;

  /// Raw bytes of the processed image
  final Uint8List bytes;

  const CryptoSuccess({required this.image, required this.bytes});
}

/// Failed result containing error information
class CryptoFailure extends CryptoResult {
  /// Error message describing what went wrong
  final String message;

  /// Optional exception that caused the failure
  final Exception? exception;

  const CryptoFailure({required this.message, this.exception});

  @override
  String toString() =>
      'CryptoFailure: $message${exception != null ? ' ($exception)' : ''}';
}
