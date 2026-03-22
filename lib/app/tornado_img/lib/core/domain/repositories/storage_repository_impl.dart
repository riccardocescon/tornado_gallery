import 'dart:typed_data';

abstract class StorageRepository {
  Future<void> save({
    required Uint8List bytes,
    required String fileName,
    required String path,
  });
}
