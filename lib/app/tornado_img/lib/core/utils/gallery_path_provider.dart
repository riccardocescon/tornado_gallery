import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/extentions.dart';

/// Resolves filesystem and virtual paths for gallery folders.
///
/// Responsibilities:
///   - Android: returns the real `Pictures/<AppName>` path.
///   - iOS: returns a virtual `ios-gallery://` path when no real path is available,
///     or the real DCIM path once at least one asset exists.
///   - Both: resolves the private encrypted folder path.
///
/// Does NOT contain business logic, scanning, or watching.
class GalleryPathProvider {
  GalleryPathProvider._();

  static const String _iosVirtualScheme = 'ios-gallery://';

  // ── Public folder path ──────────────────────────────────────────────────────

  /// Returns the filesystem path for the public gallery folder.
  ///
  /// On Android: `/sdcard/Pictures/<AppName>` (real path).
  /// On iOS: real DCIM parent path if assets exist, otherwise a virtual path.
  /// Returns null if the path cannot be resolved.
  static Future<String?> getPublicFolderPath({String? relative}) async {
    if (Platform.isAndroid) {
      final extDir = await getExternalStorageDirectory();
      if (extDir == null) return null;
      final rootPath = extDir.path.split('/Android/').first;
      final base = '$rootPath/Pictures/${Constants.appFolderName}';
      return _joinRelative(base, relative);
    }

    if (Platform.isIOS) {
      return _resolveIosPublicPath();
    }

    return null;
  }

  /// Builds the gallery album name for a folder identified by its [relative]
  /// path under the root album. `Vacanze/Mare` ⇒ `TornadoGallery/Vacanze/Mare`.
  /// A null/empty [relative] returns the root album name.
  static String getPublicAlbumName(String? relative) {
    final rel = _normalizeRelative(relative);
    return rel.isEmpty
        ? Constants.appFolderName
        : '${Constants.appFolderName}/$rel';
  }

  static Future<String?> _resolveIosPublicPath() async {
    try {
      final album = await getPublicAlbum();
      if (album == null) return null;

      final assets = await album.getAssetListPaged(page: 0, size: 1);
      if (assets.isEmpty) {
        return _buildIosVirtualPath(album);
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

      return _buildIosVirtualPath(album);
    } catch (e) {
      appLogger.logCore(
        'GalleryPathProvider: error resolving iOS path',
        error: e.toString(),
      );
      return null;
    }
  }

  // ── Private folder path ─────────────────────────────────────────────────────

  /// Returns the absolute path to the private (encrypted) folder inside the app sandbox.
  /// When [relative] is provided, resolves the nested subfolder under `encrypted/`.
  /// Creates the directory if it does not exist.
  static Future<String> getPrivateFolderPath({String? relative}) async {
    final root = await getApplicationDocumentsDirectory();
    final base = '${root.path}/encrypted';
    final directory = Directory(_joinRelative(base, relative));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  // ── Relative path helpers ─────────────────────────────────────────────────────

  /// Normalizes a relative folder path: trims, swaps backslashes, strips
  /// leading/trailing/duplicate slashes. Returns '' for null/empty input.
  static String _normalizeRelative(String? relative) {
    if (relative == null) return '';
    final cleaned = relative
        .replaceAll('\\', '/')
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .join('/');
    return cleaned;
  }

  /// Joins [base] with a normalized [relative] path.
  static String _joinRelative(String base, String? relative) {
    final rel = _normalizeRelative(relative);
    return rel.isEmpty ? base : '$base/$rel';
  }

  // ── Album access ────────────────────────────────────────────────────────────

  /// Returns the [AssetPathEntity] for the app's public album, or null if not found.
  /// Requests permission first if [requestIfNeeded] is true.
  static Future<AssetPathEntity?> getPublicAlbum({
    bool requestIfNeeded = false,
  }) async {
    try {
      final permission =
          requestIfNeeded
              ? await PhotoManager.requestPermissionExtend()
              : await PhotoManager.getPermissionState(
                requestOption: PermissionRequestOption(),
              );

      if (permission == PermissionState.denied ||
          permission == PermissionState.restricted) {
        appLogger.logCore(
          'GalleryPathProvider: permission denied (${permission.toString()})',
        );
        return null;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      return albums.firstWhereOrNull((e) => e.name == Constants.appFolderName);
    } catch (e) {
      appLogger.logCore(
        'GalleryPathProvider: error accessing album',
        error: e.toString(),
      );
      return null;
    }
  }

  /// Returns all image assets from the app's public album.
  static Future<List<AssetEntity>> getPublicAssets({
  bool requestIfNeeded = true,
}) async {
  try {
    final album = await getPublicAlbum(requestIfNeeded: requestIfNeeded);
    if (album == null) return [];
    final assets = await album.getAssetListPaged(page: 0, size: 10000);
    
    // PhotoKit returns multiple references to the same asset 
    // (e.g., TornadoGallery + Recents). Deduplicate by ID.
    final seen = <String>{};
    return assets
        .where((e) => e.type == AssetType.image && seen.add(e.id))
        .toList();
  } catch (e) {
    appLogger.logCore('GalleryPathProvider: error reading assets', error: e.toString());
    rethrow;
  }
}

  /// Returns the [AssetPathEntity] whose name equals [albumName], creating it
  /// via PhotoKit if it does not exist yet. iOS-only (album-per-folder model).
  static Future<AssetPathEntity?> getOrCreatePublicAlbum(
    String albumName,
  ) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (permission == PermissionState.denied ||
          permission == PermissionState.restricted) {
        appLogger.logCore(
          'GalleryPathProvider: permission denied creating album "$albumName"',
        );
        return null;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      final existing = albums.firstWhereOrNull((e) => e.name == albumName);
      if (existing != null) return existing;

      return await PhotoManager.editor.darwin.createAlbum(albumName);
    } catch (e) {
      appLogger.logCore(
        'GalleryPathProvider: error creating album "$albumName"',
        error: e.toString(),
      );
      return null;
    }
  }

  /// Lists gallery albums whose name starts with [prefix] (e.g.
  /// `TornadoGallery/`). Used to reconstruct the iOS folder tree from the
  /// album-name-as-path convention.
  static Future<List<AssetPathEntity>> listPublicAlbumsUnder(
    String prefix,
  ) async {
    try {
      final permission = await PhotoManager.getPermissionState(
        requestOption: PermissionRequestOption(),
      );
      if (permission == PermissionState.denied ||
          permission == PermissionState.restricted) {
        return [];
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      return albums
          .where((e) => e.name == prefix || e.name.startsWith('$prefix/'))
          .toList();
    } catch (e) {
      appLogger.logCore(
        'GalleryPathProvider: error listing albums under "$prefix"',
        error: e.toString(),
      );
      return [];
    }
  }

  // ── iOS virtual path helpers ────────────────────────────────────────────────

  static String _buildIosVirtualPath(AssetPathEntity album) {
    final encodedName = Uri.encodeComponent(album.name);
    return '$_iosVirtualScheme${album.id}/$encodedName';
  }

  /// Returns true if [path] is a virtual iOS album path (no real filesystem entry).
  static bool isVirtualPath(String? path) {
    if (path == null) return false;
    return path.startsWith(_iosVirtualScheme);
  }

  // ── Asset resolution helpers ────────────────────────────────────────────────

  /// Resolves the display filename for an asset.
  ///
  /// Prefer PhotoKit title (stable across sessions) over the file path,
  /// which on iOS can point to opaque temporary exports.
  static Future<String> resolveAssetDisplayName(
    AssetEntity asset, {
    String? fallbackFilePath,
  }) async {
    String? title = asset.title?.trim();

    if (title == null || title.isEmpty) {
      try {
        title = (await asset.titleAsync).trim();
      } catch (_) {}
    }

    if ((title == null || title.isEmpty) &&
        fallbackFilePath != null &&
        fallbackFilePath.trim().isNotEmpty) {
      title = fallbackFilePath.replaceAll('\\', '/').split('/').last;
    }

    title = (title ?? 'image').trim();
    if (title.isEmpty) return 'image.png';

    final fileLike = title.replaceAll('\\', '/').split('/').last;
    return fileLike.contains('.') ? fileLike : '$fileLike.png';
  }

  /// Searches the public album for an asset whose title starts with [fileName].
  /// Used after saving a new image to retrieve the assigned asset ID.
  static Future<String?> findAssetIdByName(String fileName) async {
    final album = await getPublicAlbum();
    if (album == null) return null;
    final assets = await album.getAssetListPaged(page: 0, size: 200);
    final baseName = fileName.split('.').first;
    final match = assets.firstWhereOrNull(
      (a) => a.title != null && a.title!.startsWith(baseName),
    );
    return match?.id;
  }

  /// Returns the asset ID of the most recently added image in the public album.
  static Future<String?> findMostRecentAssetId() async {
    final album = await getPublicAlbum(requestIfNeeded: true);
    if (album == null) return null;
    final assets = await album.getAssetListPaged(page: 0, size: 1);
    if (assets.isEmpty) return null;
    return assets.first.id;
  }
}
