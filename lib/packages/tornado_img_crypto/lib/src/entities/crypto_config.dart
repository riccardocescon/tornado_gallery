import 'dart:typed_data';

/// Configuration class for encryption/decryption operations
class CryptoConfig {
  /// The password used for encryption/decryption
  final String password;

  /// Initialization vector (IV) for AES-CTR cipher
  /// If not provided, a default IV will be generated
  final Uint8List? iv;

  /// Number of channels in the image (3 for JPEG, 4 for PNG with alpha)
  final int? numChannels;

  const CryptoConfig({required this.password, this.iv, this.numChannels});

  /// Creates a default IV (16 bytes with sequential values)
  static Uint8List get defaultIV =>
      Uint8List.fromList(List.generate(16, (i) => i));

  /// Gets the IV to use (provided or default)
  Uint8List get effectiveIV => iv ?? defaultIV;
}
