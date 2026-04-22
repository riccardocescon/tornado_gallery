import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';

class GalleryPathProvider {

  /// Ottiene tutte le immagini dell'app TornadoGallery (filtrate per nome)
  static Future<List<AssetEntity>> getImagesFromPublicGallery() async {
    try {
      final mainAlbum = await getPublicFolder();
      if (mainAlbum == null) return [];

      // Ottieni tutte le immagini dall'album principale
      final allAssets = await mainAlbum.getAssetListPaged(page: 0, size: 10000);

      // Filtra solo le immagini di TornadoGallery (che iniziano con il prefisso)
      final tornadoAssets = <AssetEntity>[];
      final validAssets = allAssets.where((e) => e.type == AssetType.image);
      tornadoAssets.addAll(validAssets);

      return tornadoAssets;
    } catch (e) {
      appLogger.logCore(
        'Error reading public gallery images',
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Returns the filesystem path for the public gallery folder, or null if
  /// the platform does not expose a real path (e.g. iOS Photos library).
  static Future<String?> getPublicFolderPath() async {
    if (Platform.isAndroid) {
      final extDir = await getExternalStorageDirectory();
      if (extDir == null) return null;
      final rootPath = extDir.path.split('/Android/').first;
      return '$rootPath/Pictures/${Constants.appFolderName}';
    }
    return null;
  }

  static Future<AssetPathEntity?> getPublicFolder({
    bool requestIfNeeded = false,
  }) async {
    try {
      final PermissionState permission;
      if (requestIfNeeded) {
        permission = await PhotoManager.requestPermissionExtend();
      } else {
        permission = await PhotoManager.getPermissionState(
          requestOption: PermissionRequestOption(),
        );
      }

      if (permission == PermissionState.denied ||
          permission == PermissionState.restricted) {
        appLogger.logCore(
          'Failed to get public folder',
          error: 'Permission denied: ${permission.toString()}',
        );
        return null;
      }

      // Ottieni l'album principale (Recent/Camera)
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      if (albums.isEmpty) return null;
      final mainAlbum = albums.firstWhereOrNull(
        (e) => e.name == Constants.appFolderName,
      );

      return mainAlbum;
    } catch (e) {
      appLogger.logCore('Error accessing public gallery', error: e.toString());
      return null;
    }
  }

  /// Ottiene il percorso della cartella privata (crittografata)
  static Future<String> getEncryptedFolderPath() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/encrypted');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  /// Metodo legacy per compatibilità
  static Future<String?> getOutputFolderRoot({
    required bool galleryVisible,
  }) async {
    if (galleryVisible) {
      // Per la galleria pubblica, ritorna null perché usiamo photo_manager
      return null;
    } else {
      return await getEncryptedFolderPath();
    }
  }
}
