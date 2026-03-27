import 'package:path_provider/path_provider.dart';

class GalleryPathProvider {
  static Future<String> getOutputFolderRoot({
    required bool galleryVisible,
  }) async {
    if (galleryVisible) {
      final root = await getExternalStorageDirectory();
      if (root != null) return '${root.path}/TornadoGallery';
    }

    final root = await getApplicationDocumentsDirectory();
    return '${root.path}/encrypted';
  }
}
