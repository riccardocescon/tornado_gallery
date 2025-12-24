part of 'homepage_bloc.dart';

class _HomepageBlocUtils {
  Future<List<EncryptedEntity>> loadLatestEncryptedImages({
    int limit = 3,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final encryptedDir = Directory('${dir.path}/encrypted');

      if (!await encryptedDir.exists()) {
        return [];
      }

      final files =
          encryptedDir.listSync().take(limit).toList()..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

      final encryptedImages = <EncryptedEntity>[];
      for (final fileSystem in files) {
        final fileName = fileSystem.path.split('/').last;
        if (fileName.contains('.')) {
          final file = File(fileSystem.path);
          final date = fileSystem.statSync().modified;
          encryptedImages.add(
            EncryptedImage(id: fileName, file: file, date: date),
          );
        } else {
          encryptedImages.add(EncryptedFolder.empty(fileSystem.path));
        }
      }

      return encryptedImages;
    } catch (e) {
      log('Error loading encrypted images: $e');
      return [];
    }
  }
}
