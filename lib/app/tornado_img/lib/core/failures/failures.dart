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

class PurchaseFailure extends Failure {
  const PurchaseFailure._({required super.message});

  factory PurchaseFailure.storeUnavailable() {
    return const PurchaseFailure._(
      message: 'The store is not available on this device.',
    );
  }

  factory PurchaseFailure.productsUnavailable() {
    return const PurchaseFailure._(
      message: 'Tornado Gallery Pro is not available right now.',
    );
  }

  factory PurchaseFailure.purchaseError(String details) {
    return PurchaseFailure._(message: 'Purchase error: $details');
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
