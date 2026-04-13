import 'package:path_provider/path_provider.dart';

class GalleryPathProvider {

  static Future<String?> getOutputFolderRoot({
    required bool galleryVisible,
  }) async {
    if (galleryVisible) return null;


    final root = await getApplicationDocumentsDirectory();
    return '${root.path}/encrypted';
  }
}
