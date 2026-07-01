import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/utils/byte_modeling.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

/// Handles all I/O for the private (encrypted) folder inside the app sandbox.
///
/// Absorbs [StorageRepositoryUtils] — the recursive scan and file-to-entity
/// mapping now live here alongside write and delete operations so all
/// private filesystem logic is in one place.
class PrivateStorageDatasource {
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

  // ── Folder operations ─────────────────────────────────────────────────────────

  /// Creates the directory at [path] (recursively). Returns false if it
  /// already exists or on error.
  Future<bool> createFolder(String path) async {
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        appLogger.logRepository(
          'PrivateStorageDatasource.createFolder: already exists',
          error: path,
        );
        return false;
      }
      await dir.create(recursive: true);
      return true;
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource.createFolder: error',
        error: e.toString(),
      );
      return false;
    }
  }

  /// Renames the directory [oldPath] to [newPath]. Returns false if the
  /// target already exists or on error.
  Future<bool> renameFolder(String oldPath, String newPath) async {
    try {
      final dir = Directory(oldPath);
      if (!await dir.exists()) return false;
      if (await Directory(newPath).exists()) {
        appLogger.logRepository(
          'PrivateStorageDatasource.renameFolder: target exists',
          error: newPath,
        );
        return false;
      }
      await dir.rename(newPath);
      return true;
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource.renameFolder: error',
        error: e.toString(),
      );
      return false;
    }
  }

  /// Deletes the directory at [path] recursively. Returns false on error.
  Future<bool> deleteFolder(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return false;
      await dir.delete(recursive: true);
      return true;
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource.deleteFolder: error',
        error: e.toString(),
      );
      return false;
    }
  }

  /// Moves the file at [oldPath] to [newPath], creating parent dirs as needed.
  /// Returns the new path on success, null on failure.
  Future<String?> moveFile(String oldPath, String newPath) async {
    try {
      final file = File(oldPath);
      if (!await file.exists()) return null;
      await Directory(File(newPath).parent.path).create(recursive: true);
      final moved = await file.rename(newPath);
      return moved.path;
    } catch (e) {
      appLogger.logRepository(
        'PrivateStorageDatasource.moveFile: error',
        error: e.toString(),
      );
      return null;
    }
  }

  // ── Directory listing ───────────────────────────────────────────────────────

  /// Yields relative paths of all subdirectories under [dir] (recursive).
  Stream<String> listSubdirectories(Directory dir) async* {
    final rootPath = dir.path.replaceAll('\\', '/');
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! Directory) continue;
      final p = entity.path.replaceAll('\\', '/');
      if (p.startsWith('$rootPath/')) yield p.substring(rootPath.length + 1);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<EncryptedImage?> _fileToImage(File file) async {
    final ext = FileNameUtils.extensionOf(file.path);
    if (!Constants.imageExtensions.contains(ext)) {
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
