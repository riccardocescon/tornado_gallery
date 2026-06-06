import 'dart:async';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/public_folder_datasource.dart';
import 'package:tornado_img_app/core/data/mappers/asset_mapper.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';

/// iOS implementation of [PublicFolderDatasource].
///
/// Uses PhotoKit (via `photo_manager`) because iOS does not expose a real,
/// stable filesystem path for gallery albums.
///
/// Change detection uses **polling** at [_pollInterval] (2 seconds): the
/// current asset ID set is compared against the previous snapshot and a
/// change event is emitted if they differ. This matches the behaviour used
/// by major iOS photo apps since PHPhotoLibraryChangeObserver is not
/// directly exposed by `photo_manager` in Dart.
class IosPublicFolderDatasource implements PublicFolderDatasource {
  static const _pollInterval = Duration(seconds: 2);

  @override
  Future<bool> createFolder() async {
    try {
      // Check if album already exists.
      final existing = await GalleryPathProvider.getPublicAlbum(
        requestIfNeeded: true,
      );
      if (existing != null) return true;

      final album = await PhotoManager.editor.darwin.createAlbum(
        Constants.appFolderName,
      );
      return album != null;
    } catch (e) {
      appLogger.logUsecase(
        'IosPublicFolderDatasource: error creating album',
        error: e.toString(),
      );
      return false;
    }
  }

  @override
  Future<List<AssetEntity>> getAssets() =>
      GalleryPathProvider.getPublicAssets(requestIfNeeded: true);

  @override
  Future<EncryptedFolder?> loadRoot() async {
    final assets = await getAssets();
    final path = await GalleryPathProvider.getPublicFolderPath();

    if (path == null || path.trim().isEmpty) return null;

    if (assets.isEmpty) {
      // Album exists but has no images yet — return empty root so the
      // watcher (poller) can attach and detect the first image.
      return EncryptedFolder.empty(path, false);
    }

    return _buildFolder(assets, path);
  }

  @override
  Stream<void> watchFolder(EncryptedFolder rootFolder) async* {
    // Seed the initial known asset ID set so the first poll does not
    // immediately emit a spurious change.
    var knownIds = await _currentAssetIds();

    while (true) {
      await Future.delayed(_pollInterval);

      Set<String> currentIds;
      try {
        currentIds = await _currentAssetIds();
      } catch (e) {
        appLogger.logPageBloc(
          'IosPublicFolderDatasource: polling error',
          error: e.toString(),
        );
        continue;
      }

      if (currentIds.length != knownIds.length ||
          !currentIds.containsAll(knownIds)) {
        knownIds = currentIds;
        yield null;
      }
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<Set<String>> _currentAssetIds() async {
    final assets = await GalleryPathProvider.getPublicAssets(
      requestIfNeeded: false,
    );
    return {for (final a in assets) a.id};
  }

  Future<EncryptedFolder> _buildFolder(
    List<AssetEntity> assets,
    String folderPath,
  ) async {
    final folder = EncryptedFolder.empty(folderPath, false);

    for (final asset in assets) {
      try {
        final image = await AssetMapper.fromAsset(
          asset: asset,
          folderPath: folderPath,
        );
        if (image != null) folder.images.add(image);
      } catch (e) {
        appLogger.logPageBloc(
          'IosPublicFolderDatasource: error mapping asset ${asset.id}',
          error: e.toString(),
        );
      }
    }

    return folder;
  }
}
