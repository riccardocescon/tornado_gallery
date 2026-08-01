sealed class Failure {
  final String message;

  const Failure({required this.message});
}

class EncryptionFailure extends Failure {
  const EncryptionFailure._({required super.message});

  factory EncryptionFailure.unsupportedExtension(String ext) {
    return EncryptionFailure._(
      message: 'Unsupported file extension for encryption: $ext',
    );
  }

  factory EncryptionFailure.encryptionError(String details) {
    return EncryptionFailure._(message: 'Encryption error: $details');
  }

  /// The source file exceeds [Constants.maxVideoBytes]. Distinct from
  /// [encryptionError] so the UI can show an actionable "too large" message
  /// instead of a generic failure.
  factory EncryptionFailure.fileTooLarge(int actualBytes, int maxBytes) {
    return EncryptionFailure._(
      message:
          'File too large: $actualBytes bytes exceeds the $maxBytes byte limit',
    );
  }

  /// A file passed to video decryption has no `uuid` ciphertext box.
  factory EncryptionFailure.notAnEncryptedVideo() {
    return EncryptionFailure._(message: 'Not an encrypted video');
  }

  /// The password's key check value does not match the stored one. Distinct
  /// from [encryptionError] so the UI can prompt for the password again
  /// instead of showing a generic error.
  factory EncryptionFailure.wrongPassword() {
    return EncryptionFailure._(message: 'Wrong password');
  }
}

class DecryptionFailure extends Failure {
  const DecryptionFailure._({required super.message});

  factory DecryptionFailure.unsupportedExtension(String ext) {
    return DecryptionFailure._(
      message: 'Unsupported file extension for decryption: $ext',
    );
  }

  factory DecryptionFailure.decryptionError(String details) {
    return DecryptionFailure._(message: 'Decryption error: $details');
  }
}
