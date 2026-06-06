import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

/// Handles all I/O for the private (encrypted) folder inside the app sandbox.
///
/// Absorbs [StorageRepositoryUtils] — the recursive scan and file-to-entity
/// mapping now live here alongside write and delete operations so all
/// private filesystem logic is in one place.
class PrivateStorageDatasource {
  static const _supportedExtensions = {'png', 'jpg', 'jpeg'};

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Recursively yields every supported image file under [dir] as an
  /// [EncryptedImage]. Skips files with unsupported extensions silently.
  Stream<EncryptedImage> readAllImages(Directory dir) async* {
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      final image = await _fileToImage(entity);
      if (image != null) yield image;
    }
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Writes [bytes] to `$path/$fileName`, creating the file if needed.
  Future<void> save({
    required String path,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final file = File('$path/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  // ── Delete ──────────────────────────────────────────────────────────────────

  /// Deletes all files at the given [paths].
  ///
  /// Returns true if at least one file was successfully deleted.
  Future<bool> delete(List<String> paths) async {
    var deleted = false;
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        deleted = true;
      } else {
        appLogger.logRepository(
          'PrivateStorageDatasource.delete: file not found',
          error: path,
        );
      }
    }
    return deleted;
  }

  // ── Rename ──────────────────────────────────────────────────────────────────

  /// Renames `$path/$oldFileName` to `$path/$newFileName`.
  ///
  /// Returns a [StorageRenameResult] indicating success or failure.
  Future<StorageRenameResult> rename({
    required String path,
    required String oldFileName,
    required String newFileName,
  }) async {
    final oldFile = File('$path/$oldFileName');
    final newFile = File('$path/$newFileName');

    if (!await oldFile.exists()) {
      appLogger.logRepository(
        'PrivateStorageDatasource.rename: source file not found',
        error: oldFile.path,
      );
      return const StorageRenameResult(success: false);
    }

    try {
      await oldFile.rename(newFile.path);
      return const StorageRenameResult(success: true);
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource.rename: error',
        error: e.toString(),
      );
      return const StorageRenameResult(success: false);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<EncryptedImage?> _fileToImage(File file) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!_supportedExtensions.contains(ext)) {
      appLogger.logRepository('PrivateStorageDatasource: unsupported file skipped: ${file.path}');
      return null;
    }

    try {
      final lastModified = await file.lastModified();
      final bytes = await file.readAsBytes();
      final hash = ByteModeling.generateHash(bytes);

      appLogger.logRepository('PrivateStorageDatasource: loaded ${file.path}');
      return EncryptedImage(
        storagePath: StoragePath(
          path: file.path,
          isPrivateFolder: true,
          assetId: null,
        ),
        encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
        date: lastModified,
      );
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource: error reading file ${file.path}',
        error: e.toString(),
      );
      return null;
    }
  }
}
