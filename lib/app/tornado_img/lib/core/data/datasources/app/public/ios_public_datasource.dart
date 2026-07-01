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

    return _buildFolder(assets, path);
  }

  @override
  Stream<void> watchFolder(EncryptedFolder rootFolder) async* {
    // Seed the initial known state so the first poll does not emit spuriously.
    var knownIds = await _currentAssetIds();
    var knownAlbums = await _currentAlbumNames();

    while (true) {
      await Future.delayed(_pollInterval);

      Set<String> currentIds;
      Set<String> currentAlbums;
      try {
        currentIds = await _currentAssetIds();
        currentAlbums = await _currentAlbumNames();
      } catch (e) {
        appLogger.logPageBloc(
          'IosPublicFolderDatasource: polling error',
          error: e.toString(),
        );
        continue;
      }

      if (currentIds.length != knownIds.length ||
          !currentIds.containsAll(knownIds) ||
          currentAlbums.length != knownAlbums.length ||
          !currentAlbums.containsAll(knownAlbums)) {
        knownIds = currentIds;
        knownAlbums = currentAlbums;
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

  Future<Set<String>> _currentAlbumNames() async {
    final albums = await GalleryPathProvider.listPublicAlbumsUnder(
      Constants.appFolderName,
    );
    return {for (final a in albums) a.name};
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

    // Reconstruct the folder tree from the album-name-as-path convention:
    // albums titled `TornadoGallery/<rel>` become nested subfolders.
    await _attachSubfolders(folder);

    return folder;
  }

  Future<void> _attachSubfolders(EncryptedFolder root) async {
    final albums = await GalleryPathProvider.listPublicAlbumsUnder(
      Constants.appFolderName,
    );

    for (final album in albums) {
      if (album.name == Constants.appFolderName) continue;
      final relative = album.name.substring(Constants.appFolderName.length + 1);
      final segments =
          relative.split('/').where((s) => s.trim().isNotEmpty).toList();
      if (segments.isEmpty) continue;

      // Walk/create the node chain for this album path.
      var current = root;
      var cumulative = Constants.appFolderName;
      for (final segment in segments) {
        cumulative = '$cumulative/$segment';
        final childPath = cumulative;
        final child = current.subfolders.firstWhere(
          (f) => f.name == segment,
          orElse: () {
            final created = EncryptedFolder.empty(childPath, false);
            current.subfolders.add(created);
            return created;
          },
        );
        current = child;
      }

      // Map this album's assets into the leaf node.
      try {
        final assets = await album.getAssetListPaged(page: 0, size: 10000);
        for (final asset in assets) {
          final image = await AssetMapper.fromAsset(
            asset: asset,
            folderPath: current.path,
          );
          if (image != null) current.images.add(image);
        }
      } catch (e) {
        appLogger.logPageBloc(
          'IosPublicFolderDatasource: error mapping album ${album.name}',
          error: e.toString(),
        );
      }
    }
  }
}
