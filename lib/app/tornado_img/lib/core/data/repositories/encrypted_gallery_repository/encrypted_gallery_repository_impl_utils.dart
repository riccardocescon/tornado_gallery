part of 'encrypted_gallery_repository_impl.dart';

/// Private utils inside the data layer
class _EncryptedGalleryRepositoryUtils {
  Future<Either<EncryptionFailure, Uint8List>> decrypt({
    required EncryptedImage image,
    required String password,
  }) async {
    try {
      final ext = image.file.path.split('.').last.toLowerCase();
      final fileBytes = await image.file.readAsBytes();

      final decodedImage = img.decodeNamedImage('file.$ext', fileBytes);

      if (decodedImage == null) {
        return Left(EncryptionFailure.unsupportedExtension(ext));
      }

      final result = await compute(_decryptImageInIsolate, (
        rawPixels: decodedImage.getBytes(),
        password: password,
      ));

      final encodedBytes = img.encodeNamedImage(
        'file.$ext',
        img.Image.fromBytes(
          width: decodedImage.width,
          height: decodedImage.height,
          bytes: result.buffer,
          numChannels: decodedImage.numChannels,
        ),
      );

      if (encodedBytes == null) {
        return Left(
          EncryptionFailure.encryptionError('Failed to encode decrypted image'),
        );
      }

      return Right(encodedBytes);
    } catch (e) {
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

Future<Uint8List> _decryptImageInIsolate(
  ({Uint8List rawPixels, String password}) task,
) async {
  return processImage(input: task.rawPixels, phrase: task.password);
}
