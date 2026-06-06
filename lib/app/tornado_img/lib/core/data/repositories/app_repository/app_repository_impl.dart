import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/datasources/app/private/private_folder_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/android_public_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/ios_public_datasource.dart';
import 'package:tornado_img_app/core/data/datasources/app/public/public_folder_datasource.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/extentions.dart';

part 'app_repository_impl_lookup.dart';

class AppRepositoryImpl implements AppRepository {
  AppRepositoryImpl()
      : _publicDatasource = Platform.isIOS
            ? IosPublicFolderDatasource()
            : AndroidPublicFolderDatasource();

  final PrivateFolderDatasource _privateDatasource = PrivateFolderDatasource();
  final PublicFolderDatasource _publicDatasource;

  // Shared mutable lookup table — updated by both private and public watchers.
  final _lookupTable = <String, EncryptedFolder>{};

  // ── AppRepository ───────────────────────────────────────────────────────────

  @override
  Future<void> dispose() async {
    // Datasources manage their own stream lifecycles.
    _lookupTable.clear();
  }

  @override
  Future<EncryptedFolder> loadPrivateRootFolder() async {
    final root = await _privateDatasource.loadRoot();
    _lookupTable.addAll(_buildIndex(root));
    return root;
  }

  @override
  Future<EncryptedFolder?> loadPublicRootFolder() async {
    final root = await _publicDatasource.loadRoot();
    if (root == null) return null;
    _lookupTable.addAll(_buildIndex(root));
    return root;
  }

  @override
  Stream<void> watchFolderChanges(EncryptedFolder rootFolder) {
    if (rootFolder.isPrivateFolder) {
      return _privateDatasource.watchFolder(
        rootFolder: rootFolder,
        lookupTable: _lookupTable,
        rescan: _privateDatasource.scanFolder,
        removeFolder: _removeFolderFromTree,
        insertFolder: _insertFolder,
        addToLookup: _lookupTable.addAll,
        removeLookupBranch: _removeLookupBranch,
      );
    }

    return _publicDatasource.watchFolder(rootFolder);
  }

  @override
  Future<bool> createPublicFolder() => _publicDatasource.createFolder();

  @override
  Future<List<GalleryImage>> mapAssetsToGalleryImages(
    List<AssetEntity> assets,
  ) async {
    final images = <GalleryImage>[];

    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        // Strip the extension suffix that photo_manager appends to the id
        // on some Android versions (e.g. "12345.jpg" → "12345").
        final rawId = asset.id;
        final cleanId = rawId.contains('.')
            ? rawId.substring(0, rawId.lastIndexOf('.'))
            : rawId;

        images.add(
          GalleryImage(id: cleanId, file: file, date: asset.createDateTime),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'AppRepositoryImpl: error mapping asset ${asset.id}',
          error: e.toString(),
        );
      }
    }

    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }
}
