import 'dart:io';
import 'dart:typed_data';
import 'package:tornado_img_app/core/domain/repositories/storage_repository_impl.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String path,
  }) async {

    final file = File('$path/$fileName');

    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }
}
