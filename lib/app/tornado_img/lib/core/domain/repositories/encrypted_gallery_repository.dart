import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

abstract class EncryptedGalleryRepository {
  Future<Either<EncryptionFailure, Uint8List>> decryptImage({
    required EncryptedImage image,
    required String password,
  });

  Future<Either<EncryptionFailure, List<EncryptedImage>>> decryptFolder({
    required List<EncryptedImage> images,
    required String password,
  });

  Future<Either<EncryptionFailure, void>> deleteFolder(String folderName);

  Future<Directory> getEncryptedFolder();
}
