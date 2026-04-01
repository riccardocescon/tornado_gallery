import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import '../../../domain/repositories/encrypted_gallery_repository.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

part 'encrypted_gallery_repository_impl_utils.dart';

class EncryptedGalleryRepositoryImpl implements EncryptedGalleryRepository {
  final _utils = _EncryptedGalleryRepositoryUtils();

  @override
  Future<Either<EncryptionFailure, Uint8List>> decryptImage({
    required EncryptedImage image,
    required String password,
  }) async {
    try {
      return await _utils.decrypt(image: image, password: password);
    } catch (e) {
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }

  @override
  Future<Either<EncryptionFailure, List<EncryptedImage>>> decryptFolder({
    required List<EncryptedImage> images,
    required String password,
  }) async {
    final result = <EncryptedImage>[];
    for (final image in images) {
      final res = await decryptImage(image: image, password: password);
      res.fold((_) {}, (bytes) {
        image.bytes = bytes;
        result.add(image);
      });
    }
    return Right(result);
  }

  @override
  Future<Either<EncryptionFailure, void>> deleteFolder(
    String folderName,
  ) async {
    try {
      final baseDir = await getEncryptedFolder();
      final folder = Directory('${baseDir.path}/$folderName');
      if (await folder.exists()) await folder.delete(recursive: true);
      return const Right(null);
    } catch (e) {
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }

  @override
  Future<Directory> getEncryptedFolder() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory('${dir.path}/encrypted');
  }
}
