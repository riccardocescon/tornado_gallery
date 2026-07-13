import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Persists a local JSON index that maps asset IDs and content hashes to
/// display filenames for public gallery images.
///
/// This is needed because on iOS, PhotoKit does not guarantee stable filenames
/// across sessions — we store the original name at save time and look it up later.
class AssetNameIndex {
  AssetNameIndex._();

  static const _indexFileName = '.public_gallery_names.json';

  // ── Public write API ────────────────────────────────────────────────────────

  static Future<void> saveByHash({
    required String hash,
    required String fileName,
  }) async {
    try {
      final index = await _read();
      index[hash] = _normalize(fileName);
      await _write(index);
    } catch (e) {
      appLogger.log(
        'AssetNameIndex: error saving by hash',
        LogLayer.core,
        error: e.toString(),
      );
    }
  }

  static Future<void> saveByAssetId({
    required String assetId,
    required String fileName,
  }) async {
    try {
      final index = await _read();
      index['asset:$assetId'] = _normalize(fileName);
      await _write(index);
    } catch (e) {
      appLogger.log(
        'AssetNameIndex: error saving by assetId',
        LogLayer.core,
        error: e.toString(),
      );
    }
  }

  // ── Public read API ─────────────────────────────────────────────────────────

  static Future<String?> resolveByAssetId(String assetId) async {
    try {
      final index = await _read();
      final value = index['asset:$assetId']?.trim();
      if (value == null || value.isEmpty) return null;
      return _normalize(value);
    } catch (e) {
      appLogger.log(
        'AssetNameIndex: error reading by assetId',
        LogLayer.core,
        error: e.toString(),
      );
      return null;
    }
  }

  static Future<String?> resolveByHash(String hash) async {
    try {
      final index = await _read();
      final value = index[hash]?.trim();
      if (value == null || value.isEmpty) return null;
      return _normalize(value);
    } catch (e) {
      appLogger.log(
        'AssetNameIndex: error reading by hash',
        LogLayer.core,
        error: e.toString(),
      );
      return null;
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static Future<File> _indexFile() async {
    final root = await getApplicationDocumentsDirectory();
    return File('${root.path}/$_indexFileName');
  }

  static Future<Map<String, String>> _read() async {
    final file = await _indexFile();
    if (!await file.exists()) return {};
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map((k, v) => MapEntry('$k', '$v'));
  }

  static Future<void> _write(Map<String, String> index) async {
    final file = await _indexFile();
    if (!await file.exists()) await file.create(recursive: true);
    await file.writeAsString(jsonEncode(index));
  }

  static String _normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'image.png';
    final fileLike = FileNameUtils.basename(trimmed);
    return fileLike.contains('.') ? fileLike : '$fileLike.png';
  }
}
