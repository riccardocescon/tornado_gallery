// import 'dart:convert';
// import 'dart:io';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/widgets.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:tornado_img_app/core/utils/constants.dart';
// import 'package:tornado_img_app/core/utils/globals.dart';
// import 'package:tornado_img_app/extentions.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// class GalleryPathProvider {
//   static const String _iosGalleryScheme = 'ios-gallery://';

//   static String _buildIosAlbumVirtualPath(AssetPathEntity album) {
//     final encodedName = Uri.encodeComponent(album.name);
//     return '$_iosGalleryScheme${album.id}/$encodedName';
//   }

//   static Future<List<AssetEntity>> getImagesFromPublicGallery() async {
//     try {
//       final mainAlbum = await getPublicFolder(requestIfNeeded: true);
//       if (mainAlbum == null) return [];

//       final allAssets = await mainAlbum.getAssetListPaged(page: 0, size: 10000);

//       final tornadoAssets = <AssetEntity>[];
//       final validAssets = allAssets.where((e) => e.type == AssetType.image);
//       tornadoAssets.addAll(validAssets);

//       return tornadoAssets;
//     } catch (e) {
//       appLogger.logCore(
//         'Error reading public gallery images',
//         error: e.toString(),
//       );
//       rethrow;
//     }
//   }

//   /// Returns the filesystem path for the public gallery folder, or null if
//   /// the platform does not expose a real path
//   static Future<String?> getPublicFolderPath() async {
//     if (Platform.isAndroid) {
//       final extDir = await getExternalStorageDirectory();
//       if (extDir == null) return null;
//       final rootPath = extDir.path.split('/Android/').first;
//       return '$rootPath/Pictures/${Constants.appFolderName}';
//     }

//     if (Platform.isIOS) {
//       try {
//         final album = await getPublicFolder(requestIfNeeded: true);
//         if (album == null) return null;

//         final assets = await album.getAssetListPaged(page: 0, size: 1);
//         if (assets.isEmpty) {
//           return _buildIosAlbumVirtualPath(album);
//         }

//         final asset = assets.first;
//         final file = await asset.originFile ?? await asset.file;
//         final parentPath = file?.parent.path;
//         if (parentPath != null && parentPath.trim().isNotEmpty) {
//           return parentPath;
//         }

//         final relativePath = asset.relativePath;
//         if (relativePath != null && relativePath.trim().isNotEmpty) {
//           return relativePath;
//         }

//         return _buildIosAlbumVirtualPath(album);
//       } catch (e) {
//         appLogger.logCore(
//           'Error resolving iOS public folder path',
//           error: e.toString(),
//         );

//         return null;
//       }
//     }

//     return null;
//   }

//   static bool isIosVirtualGalleryPath(String? path) {
//     if (path == null) return false;
//     return path.startsWith(_iosGalleryScheme);
//   }

//   static Future<AssetPathEntity?> getPublicFolder({
//     bool requestIfNeeded = false,
//   }) async {
//     try {
//       final PermissionState permission;
//       if (requestIfNeeded) {
//         permission = await PhotoManager.requestPermissionExtend();
//       } else {
//         permission = await PhotoManager.getPermissionState(
//           requestOption: PermissionRequestOption(),
//         );
//       }

//       if (permission == PermissionState.denied ||
//           permission == PermissionState.restricted) {
//         appLogger.logCore(
//           'Failed to get public folder',
//           error: 'Permission denied: ${permission.toString()}',
//         );
//         return null;
//       }

//       // Ottieni l'album principale (Recent/Camera)
//       final albums = await PhotoManager.getAssetPathList(
//         type: RequestType.image,
//         hasAll: true,
//       );

//       if (albums.isEmpty) return null;
//       final mainAlbum = albums.firstWhereOrNull(
//         (e) => e.name == Constants.appFolderName,
//       );

//       return mainAlbum;
//     } catch (e) {
//       appLogger.logCore('Error accessing public gallery', error: e.toString());
//       return null;
//     }
//   }

//   /// Ottiene il percorso della cartella privata (crittografata)
//   static Future<String> getEncryptedFolderPath() async {
//     final root = await getApplicationDocumentsDirectory();
//     final directory = Directory('${root.path}/encrypted');
//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }
//     return directory.path;
//   }

//   /// After saving a new image to the public gallery, call this with the exact
//   /// [fileName] (without extension) to retrieve the asset ID that PhotoManager
//   /// assigned to it. Returns null if not found.
//   static Future<String?> findGalleryAssetIdByName(String fileName) async {
//     final album = await getPublicFolder();
//     if (album == null) return null;
//     // Load a batch of recent assets to find the matching one by title.
//     final assets = await album.getAssetListPaged(page: 0, size: 200);
//     final baseName = fileName.split('.').first;
//     final match = assets.firstWhereOrNull(
//       (a) => a.title != null && a.title!.startsWith(baseName),
//     );
//     return match?.id;
//   }

//   /// Resolves a stable display filename for a gallery asset.
//   ///
//   /// On iOS, `asset.file.path` can point to temporary exports with opaque
//   /// names; prefer PhotoKit title/original filename so UI names survive restarts.
//   static Future<String> resolveAssetDisplayFileName(
//     AssetEntity asset, {
//     String? fallbackFilePath,
//   }) async {
//     String? title = asset.title?.trim();

//     if (title == null || title.isEmpty) {
//       try {
//         title = (await asset.titleAsync).trim();
//       } catch (_) {
//         // Keep fallback behavior below when title fetch fails.
//       }
//     }

//     if ((title == null || title.isEmpty) &&
//         fallbackFilePath != null &&
//         fallbackFilePath.trim().isNotEmpty) {
//       title = fallbackFilePath.replaceAll('\\\\', '/').split('/').last;
//     }

//     title = (title ?? 'image').trim();
//     if (title.isEmpty) {
//       return 'image.png';
//     }

//     final fileLike = title.replaceAll('\\\\', '/').split('/').last;
//     if (!fileLike.contains('.')) {
//       return '$title.png';
//     }
//     return title;
//   }

//   static Future<void> rememberPublicImageName({
//     required String hash,
//     required String fileName,
//   }) async {
//     try {
//       final index = await _readPublicNameIndex();
//       index[hash] = _normalizeDisplayName(fileName);
//       await _writePublicNameIndex(index);
//     } catch (e) {
//       appLogger.logCore(
//         'Error saving public image name index',
//         error: e.toString(),
//       );
//     }
//   }

//   static Future<void> rememberPublicImageNameForAsset({
//     required String assetId,
//     required String fileName,
//   }) async {
//     try {
//       final index = await _readPublicNameIndex();
//       index['asset:$assetId'] = _normalizeDisplayName(fileName);
//       await _writePublicNameIndex(index);
//     } catch (e) {
//       appLogger.logCore(
//         'Error saving public image asset-name index',
//         error: e.toString(),
//       );
//     }
//   }

//   static Future<String?> resolvePublicImageNameByAssetId(String assetId) async {
//     try {
//       final index = await _readPublicNameIndex();
//       final value = index['asset:$assetId']?.trim();
//       if (value == null || value.isEmpty) return null;
//       return _normalizeDisplayName(value);
//     } catch (e) {
//       appLogger.logCore(
//         'Error reading public image asset-name index',
//         error: e.toString(),
//       );
//       return null;
//     }
//   }

//   static Future<String?> resolvePublicImageNameByHash(String hash) async {
//     try {
//       final index = await _readPublicNameIndex();
//       final value = index[hash]?.trim();
//       if (value == null || value.isEmpty) return null;
//       return _normalizeDisplayName(value);
//     } catch (e) {
//       appLogger.logCore(
//         'Error reading public image name index',
//         error: e.toString(),
//       );
//       return null;
//     }
//   }

//   static Future<String?> findMostRecentPublicAssetId() async {
//     final album = await getPublicFolder(requestIfNeeded: true);
//     if (album == null) return null;
//     final assets = await album.getAssetListPaged(page: 0, size: 1);
//     if (assets.isEmpty) return null;
//     return assets.first.id;
//   }

//   static Future<File> _publicNameIndexFile() async {
//     final root = await getApplicationDocumentsDirectory();
//     return File('${root.path}/.public_gallery_names.json');
//   }

//   static Future<Map<String, String>> _readPublicNameIndex() async {
//     final file = await _publicNameIndexFile();
//     if (!await file.exists()) return <String, String>{};

//     final raw = await file.readAsString();
//     if (raw.trim().isEmpty) return <String, String>{};

//     final decoded = jsonDecode(raw);
//     if (decoded is! Map) return <String, String>{};

//     return decoded.map((key, value) => MapEntry('$key', '$value'));
//   }

//   static Future<void> _writePublicNameIndex(Map<String, String> index) async {
//     final file = await _publicNameIndexFile();
//     if (!await file.exists()) {
//       await file.create(recursive: true);
//     }
//     await file.writeAsString(jsonEncode(index));
//   }

//   static String _normalizeDisplayName(String raw) {
//     final trimmed = raw.trim();
//     if (trimmed.isEmpty) return 'image.png';
//     final fileLike = trimmed.replaceAll('\\', '/').split('/').last;
//     if (!fileLike.contains('.')) {
//       return '$fileLike.png';
//     }
//     return fileLike;
//   }

//   /// Metodo legacy per compatibilità
//   static Future<String?> getOutputFolderRoot({
//     required bool galleryVisible,
//   }) async {
//     if (galleryVisible) {
//       // For public gallery, we are using_manager
//       return null;
//     } else {
//       return await getEncryptedFolderPath();
//     }
//   }
// }

// class PicturesProvider {
//   static Future<Either<String?, List<AssetEntity>>> pickImagesFromGallery(
//     BuildContext context,
//   ) async {
//     final permissionState = await PhotoManager.requestPermissionExtend();
//     if (!context.mounted) return Left(null);
//     if (!permissionState.isAuth && !permissionState.isLimited) {
//       return Left("Permission to access photos was denied");
//     }

//     final assets = await AssetPicker.pickAssets(
//       context,
//       pickerConfig: AssetPickerConfig(
//         requestType: RequestType.image,
//         maxAssets: 100,
//       ),
//     );
//     if (!context.mounted) return Left(null);
//     if (assets?.isEmpty ?? true) {
//       return Left("No images selected");
//     }

//     return Right(assets!);
//   }
// }
