import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository_impl.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    String? customPath,
  }) async {
    final baseDir =
        customPath ?? (await getApplicationDocumentsDirectory()).path;

    final file = File('$baseDir/encrypted/$fileName');

    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }
}
