import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/providers.dart';

Future<List<String>> getFolderPaths() async {
  // Get the application documents directory
  final appDir = await getApplicationDocumentsDirectory();
  String path = '${appDir.path}/encrypted';
  final encryptedDir = Directory(path);
  if (!encryptedDir.existsSync()) {
    await encryptedDir.create(recursive: true);
  }

  final folders = encryptedDir.listSync(recursive: true).whereType<Directory>();
  return folders.map((dir) => dir.path).toList();
}

Future<String> getPublicFolderAssetPath({
  required AssetEntity asset,
  required String absoluteFolderPath,
  required String hash,
  required String filePath,
}) async {
  if (Platform.isAndroid) return '$absoluteFolderPath/${asset.title}';

  if (Platform.isIOS) {
    final mappedByAssetId =
        await GalleryPathProvider.resolvePublicImageNameByAssetId(asset.id);
    final mappedFileName =
        mappedByAssetId ??
        await GalleryPathProvider.resolvePublicImageNameByHash(hash);
    final displayFileName =
        mappedFileName ??
        await GalleryPathProvider.resolveAssetDisplayFileName(
          asset,
          fallbackFilePath: filePath,
        );
    return '$absoluteFolderPath/$displayFileName';
  }

  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}
