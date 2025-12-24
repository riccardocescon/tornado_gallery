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
}
