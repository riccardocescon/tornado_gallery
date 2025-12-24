part of 'encrypted_gallery_bloc.dart';

class _EncryptedGalleryBlocUtils {
  Future<Either<EncryptionFailure, Uint8List>> decrypt({
    required EncryptedImage image,
    required String password,
  }) async {
    final ext = image.file.path.split('.').last.toLowerCase();
    final fileBytes = await image.file.readAsBytes();

    final decodedImage = ImageCrypto.decodeImageFromBytes(
      bytes: fileBytes,
      extension: ext,
    );

    if (decodedImage == null) {
      log('Failed to decode image or unsupported format: $ext');
      return Left(EncryptionFailure.unsupportedExtension(ext));
    }

    final fileParts = image.file.path.split('.');
    final originalExt = fileParts[fileParts.length - 2].toLowerCase();

    final config = CryptoConfig(
      password: password,
      numChannels: originalExt == 'png' ? 4 : null,
    );

    final initDecryptTime = DateTime.now();
    final result = await ImageCrypto.decryptImageObject(
      image: decodedImage,
      config: config,
    );
    final decryptDuration = DateTime.now().difference(initDecryptTime);
    log('Image decrypted in ${decryptDuration.inMilliseconds} ms');

    if (result case CryptoFailure failure) {
      log('Decryption failed: ${failure.message}');
      return Left(EncryptionFailure.encryptionError(failure.message));
    }

    if (result case CryptoSuccess success) {
      final data = ImageCrypto.encodeImageToBytes(
        image: success.image,
        extension: ext,
      );
      if (data == null) {
        return Left(
          EncryptionFailure.encryptionError(
            'Failed to encode decrypted image to bytes',
          ),
        );
      }

      return Right(data);
    }

    return Left(
      EncryptionFailure.encryptionError('Unknown error during decryption'),
    );
  }
}
