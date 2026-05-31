import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GalleryPathProvider {
  static const String _iosGalleryScheme = 'ios-gallery://';

  static String _buildIosAlbumVirtualPath(AssetPathEntity album) {
    final encodedName = Uri.encodeComponent(album.name);
    return '$_iosGalleryScheme${album.id}/$encodedName';
  }

  /// Ottiene tutte le immagini dell'app TornadoGallery (filtrate per nome)
  static Future<List<AssetEntity>> getImagesFromPublicGallery() async {
    try {
      final mainAlbum = await getPublicFolder(requestIfNeeded: true);
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
  /// the platform does not expose a real path
  static Future<String?> getPublicFolderPath() async {
    if (Platform.isAndroid) {
      final extDir = await getExternalStorageDirectory();
      if (extDir == null) return null;
      final rootPath = extDir.path.split('/Android/').first;
      return '$rootPath/Pictures/${Constants.appFolderName}';
    } else if (Platform.isIOS) {
      try {
        final album = await getPublicFolder(requestIfNeeded: true);
        if (album == null) return null;

        final assets = await album.getAssetListPaged(page: 0, size: 1);
        if (assets.isEmpty) {
          return _buildIosAlbumVirtualPath(album);
        }

        final asset = assets.first;
        final file = await asset.originFile ?? await asset.file;
        final parentPath = file?.parent.path;
        if (parentPath != null && parentPath.trim().isNotEmpty) {
          return parentPath;
        }

        final relativePath = asset.relativePath;
        if (relativePath != null && relativePath.trim().isNotEmpty) {
          return relativePath;
        }

        return _buildIosAlbumVirtualPath(album);
      } catch (e) {
        appLogger.logCore(
          'Error resolving iOS public folder path',
          error: e.toString(),
        );
      }
    }
    return null;
  }

  static bool isIosVirtualGalleryPath(String? path) {
    if (path == null) return false;
    return path.startsWith(_iosGalleryScheme);
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

  /// After saving a new image to the public gallery, call this with the exact
  /// [fileName] (without extension) to retrieve the asset ID that PhotoManager
  /// assigned to it. Returns null if not found.
  static Future<String?> findGalleryAssetIdByName(String fileName) async {
    final album = await getPublicFolder();
    if (album == null) return null;
    // Load a batch of recent assets to find the matching one by title.
    final assets = await album.getAssetListPaged(page: 0, size: 200);
    final baseName = fileName.split('.').first;
    final match = assets.firstWhereOrNull(
      (a) => a.title != null && a.title!.startsWith(baseName),
    );
    return match?.id;
  }

  /// Metodo legacy per compatibilità
  static Future<String?> getOutputFolderRoot({
    required bool galleryVisible,
  }) async {
    if (galleryVisible) {
      // For public gallery, we are using_manager
      return null;
    } else {
      return await getEncryptedFolderPath();
    }
  }
}

class PicturesProvider {
  static Future<Either<String?, List<AssetEntity>>> pickImagesFromGallery(
    BuildContext context,
  ) async {
    final permissionState = await PhotoManager.requestPermissionExtend();
    if (!context.mounted) return Left(null);
    if (!permissionState.isAuth && !permissionState.isLimited) {
      return Left("Permission to access photos was denied");
    }

    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.image,
        maxAssets: 100,
      ),
    );
    if (!context.mounted) return Left(null);
    if (assets?.isEmpty ?? true) {
      return Left("No images selected");
    }

    return Right(assets!);
  }
}
