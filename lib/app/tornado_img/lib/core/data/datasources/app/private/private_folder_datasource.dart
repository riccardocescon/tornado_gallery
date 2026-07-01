import 'dart:async';
import 'dart:io';

import 'package:tornado_img_app/core/managers/stream_manager.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/mappers/file_mapper.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_folder.dart';
import 'package:watcher/watcher.dart';

/// Handles all I/O for the private (encrypted) folder inside the app sandbox.
///
/// Responsibilities:
///   - Scan the folder tree recursively and return an [EncryptedFolder].
///   - Watch the folder for filesystem changes and emit events via a [Stream].
///
/// Has no knowledge of the public gallery or platform-specific gallery APIs.
class PrivateFolderDatasource {
  // ── Scan ────────────────────────────────────────────────────────────────────

  /// Scans [path] recursively and returns a fully populated [EncryptedFolder].
  Future<EncryptedFolder> scanFolder(String path) async {
    return _scanRecursive(path, isRoot: true);
  }

  /// Loads the private root folder, creating it if it does not exist.
  Future<EncryptedFolder> loadRoot() async {
    final path = await GalleryPathProvider.getPrivateFolderPath();
    return scanFolder(path);
  }

  Future<EncryptedFolder> _scanRecursive(
    String path, {
    bool isRoot = false,
  }) async {
    final folder = EncryptedFolder.empty(path, true);

    List<FileSystemEntity> entries;
    try {
      entries = Directory(path).listSync();
    } catch (e) {
      appLogger.logRepository(
        'PrivateFolderDatasource: cannot list directory $path',
        error: e.toString(),
      );
      return folder;
    }

    for (final entry in entries) {
      final name = entry.path.split(Platform.pathSeparator).last;
      final isFile = name.contains('.');

      if (isFile) {
        final image = await FileMapper.fromFile(
          file: File(entry.path),
          isPrivateFolder: true,
        );
        if (image != null) folder.images.add(image);
      } else {
        final subfolder = await _scanRecursive(entry.path);
        folder.subfolders.add(subfolder);
      }
    }

    return folder;
  }

  // ── Watch ───────────────────────────────────────────────────────────────────

  /// Returns a stream of filesystem change events for [rootFolder].
  ///
  /// The stream emits `null` whenever the folder tree has changed and the
  /// caller should re-read from the in-memory [EncryptedFolder] tree.
  ///
  /// Internally:
  ///   - ADD events are applied immediately.
  ///   - REMOVE events are coalesced with a 700ms window to distinguish
  ///     true deletions from rename/move (REMOVE + ADD pairs).
  ///   - MODIFY events are ignored (content changes are not relevant here).
  Stream<void> watchFolder({
    required EncryptedFolder rootFolder,
    required Map<String, EncryptedFolder> lookupTable,
    required Future<EncryptedFolder> Function(String path) rescan,
    required bool Function(EncryptedFolder root, EncryptedFolder folder)
    removeFolder,
    required bool Function({
      required EncryptedFolder rootFolder,
      required EncryptedFolder newFolder,
    })
    insertFolder,
    required void Function(Map<String, EncryptedFolder> index) addToLookup,
    required void Function(String rootPath) removeLookupBranch,
  }) async* {
    if (rootFolder.path.trim().isEmpty) {
      appLogger.logPageBloc(
        'PrivateFolderDatasource: skipping watcher, empty path',
      );
      return;
    }

    final dir = Directory(rootFolder.path);
    if (!await dir.exists()) {
      appLogger.logPageBloc(
        'PrivateFolderDatasource: skipping watcher, folder does not exist (${rootFolder.path})',
      );
      return;
    }

    // On macOS/iOS /var is a symlink to /private/var. FSEvents always delivers
    // resolved paths — resolve once so we can normalise incoming event paths.
    String resolvedRoot;
    try {
      resolvedRoot = await dir.resolveSymbolicLinks();
    } on FileSystemException {
      resolvedRoot = rootFolder.path;
    }
    final originalRoot = rootFolder.path;

    String normalizePath(String p) {
      if (originalRoot != resolvedRoot && p.startsWith(resolvedRoot)) {
        return originalRoot + p.substring(resolvedRoot.length);
      }
      return p;
    }

    final watcher = DirectoryWatcher(dir.path);
    final sm = StreamManager.fromStream(watcher.events);
    await watcher.ready;

    final pendingRemovals = <String, DateTime>{};
    const coalesceWindow = Duration(milliseconds: 700);

    final mergedController = StreamController<WatchEvent?>();

    void schedulePendingFlush() {
      Future.delayed(coalesceWindow + const Duration(milliseconds: 50), () {
        if (!mergedController.isClosed) mergedController.add(null);
      });
    }

    final fsSub = sm.stream.listen(
      (e) {
        if (!mergedController.isClosed) mergedController.add(e);
      },
      onDone: () => mergedController.close(),
      onError: (Object e, StackTrace s) {
        if (!mergedController.isClosed) mergedController.addError(e, s);
      },
    );

    try {
      await for (final event in mergedController.stream) {
        // Flush expired removals first on every tick.
        final flushed = _flushExpiredRemovals(
          rootFolder: rootFolder,
          pendingRemovals: pendingRemovals,
          window: coalesceWindow,
          lookupTable: lookupTable,
          removeFolder: removeFolder,
          removeLookupBranch: removeLookupBranch,
        );
        if (flushed) yield null;

        // null = delayed flush pulse only, nothing more to do.
        if (event == null) continue;

        if (event.type == ChangeType.MODIFY) continue;

        final path = normalizePath(event.path);

        if (event.type == ChangeType.REMOVE) {
          pendingRemovals[path] = DateTime.now();
          schedulePendingFlush();
          continue;
        }

        // ADD event — check if it's the ADD half of a rename/move pair.
        final movedFrom = _takeMoveSourceCandidate(pendingRemovals, path);
        if (movedFrom != null) {
          final moved = await _applyMove(
            rootFolder: rootFolder,
            fromPath: movedFrom,
            toPath: path,
            rootPath: originalRoot,
            lookupTable: lookupTable,
            rescan: rescan,
            removeFolder: removeFolder,
            insertFolder: insertFolder,
            addToLookup: addToLookup,
            removeLookupBranch: removeLookupBranch,
          );
          if (moved) {
            yield null;
            continue;
          }
          // Not a true move — process as separate remove + add.
          _applyRemove(
            path: movedFrom,
            rootFolder: rootFolder,
            lookupTable: lookupTable,
            removeFolder: removeFolder,
            removeLookupBranch: removeLookupBranch,
          );
        }

        // Process as new ADD.
        final isDirectory =
            Directory(path).existsSync() || !path.split('/').last.contains('.');

        if (isDirectory) {
          final newFolder = await rescan(path);
          final inserted = insertFolder(
            rootFolder: rootFolder,
            newFolder: newFolder,
          );
          if (inserted) {
            addToLookup(_buildIndex(newFolder));
            yield null;
          }
          continue;
        }

        // File ADD.
        final parentPath = Directory(path).parent.path;
        EncryptedFolder? parentFolder = lookupTable[parentPath];

        if (parentFolder == null) {
          final recovered = await _recoverParent(
            rootFolder: rootFolder,
            parentPath: parentPath,
            rootPath: originalRoot,
            lookupTable: lookupTable,
            rescan: rescan,
            insertFolder: insertFolder,
            addToLookup: addToLookup,
          );
          if (recovered) parentFolder = lookupTable[parentPath];
        }

        if (parentFolder == null) {
          appLogger.logPageBloc(
            'PrivateFolderDatasource: parent not found for $path',
          );
          continue;
        }

        final file = File(path);
        if (!file.existsSync()) continue; // Race condition: already deleted.

        final image = await FileMapper.fromFile(
          file: file,
          isPrivateFolder: true,
        );
        if (image == null) continue;

        final wasPresent = parentFolder.images.any(
          (img) => img.storagePath.path == path,
        );
        parentFolder.images.removeWhere((img) => img.storagePath.path == path);
        parentFolder.images.add(image);
        if (!wasPresent) yield null;
      }

      // Drain any remaining removals when the stream ends.
      for (final path in pendingRemovals.keys.toList()) {
        _applyRemove(
          path: path,
          rootFolder: rootFolder,
          lookupTable: lookupTable,
          removeFolder: removeFolder,
          removeLookupBranch: removeLookupBranch,
        );
      }
    } finally {
      await fsSub.cancel();
      await mergedController.close();
      await sm.dispose();
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  bool _flushExpiredRemovals({
    required EncryptedFolder rootFolder,
    required Map<String, DateTime> pendingRemovals,
    required Duration window,
    required Map<String, EncryptedFolder> lookupTable,
    required bool Function(EncryptedFolder, EncryptedFolder) removeFolder,
    required void Function(String) removeLookupBranch,
  }) {
    final now = DateTime.now();
    final expired =
        pendingRemovals.entries
            .where((e) => now.difference(e.value) >= window)
            .map((e) => e.key)
            .toList();

    var changed = false;
    for (final path in expired) {
      pendingRemovals.remove(path);
      changed =
          _applyRemove(
            path: path,
            rootFolder: rootFolder,
            lookupTable: lookupTable,
            removeFolder: removeFolder,
            removeLookupBranch: removeLookupBranch,
          ) ||
          changed;
    }
    return changed;
  }

  bool _applyRemove({
    required String path,
    required EncryptedFolder rootFolder,
    required Map<String, EncryptedFolder> lookupTable,
    required bool Function(EncryptedFolder, EncryptedFolder) removeFolder,
    required void Function(String) removeLookupBranch,
  }) {
    final folder = lookupTable[path];
    if (folder != null) {
      removeFolder(rootFolder, folder);
      removeLookupBranch(path);
      appLogger.logPageBloc('PrivateFolderDatasource: folder removed $path');
      return true;
    }

    final parentPath = Directory(path).parent.path;
    final parentFolder = lookupTable[parentPath];
    if (parentFolder != null) {
      final hadImage = parentFolder.images.any(
        (img) => img.storagePath.path == path,
      );
      if (hadImage) {
        parentFolder.images.removeWhere((img) => img.storagePath.path == path);
        appLogger.logPageBloc('PrivateFolderDatasource: file removed $path');
        return true;
      }
    }

    appLogger.logPageBloc(
      'PrivateFolderDatasource: path not found for removal $path',
    );
    return false;
  }

  Future<bool> _applyMove({
    required EncryptedFolder rootFolder,
    required String fromPath,
    required String toPath,
    required String rootPath,
    required Map<String, EncryptedFolder> lookupTable,
    required Future<EncryptedFolder> Function(String) rescan,
    required bool Function(EncryptedFolder, EncryptedFolder) removeFolder,
    required bool Function({
      required EncryptedFolder rootFolder,
      required EncryptedFolder newFolder,
    })
    insertFolder,
    required void Function(Map<String, EncryptedFolder>) addToLookup,
    required void Function(String) removeLookupBranch,
  }) async {
    // Folder move/rename.
    final movedFolder = lookupTable[fromPath];
    if (movedFolder != null) {
      removeFolder(rootFolder, movedFolder);
      removeLookupBranch(fromPath);
      final rescanned = await rescan(toPath);
      final inserted = insertFolder(
        rootFolder: rootFolder,
        newFolder: rescanned,
      );
      if (!inserted) return false;
      addToLookup(_buildIndex(rescanned));
      appLogger.logPageBloc(
        'PrivateFolderDatasource: folder moved $fromPath -> $toPath',
      );
      return true;
    }

    // File move/rename.
    final fromParentPath = Directory(fromPath).parent.path;
    final toParentPath = Directory(toPath).parent.path;
    final fromParent = lookupTable[fromParentPath];
    if (fromParent == null) return false;

    EncryptedFolder? toParent = lookupTable[toParentPath];
    if (toParent == null) {
      final recovered = await _recoverParent(
        rootFolder: rootFolder,
        parentPath: toParentPath,
        rootPath: rootPath,
        lookupTable: lookupTable,
        rescan: rescan,
        insertFolder: insertFolder,
        addToLookup: addToLookup,
      );
      if (recovered) toParent = lookupTable[toParentPath];
    }
    if (toParent == null) return false;

    final idx = fromParent.images.indexWhere(
      (img) => img.storagePath.path == fromPath,
    );
    if (idx == -1) return false;

    final movedImage = fromParent.images.removeAt(idx);
    final updatedImage = movedImage.copyWith(
      storagePath: movedImage.storagePath.copyWith(path: toPath),
    );
    toParent.images.removeWhere((img) => img.storagePath.path == toPath);
    toParent.images.add(updatedImage);
    appLogger.logPageBloc(
      'PrivateFolderDatasource: file moved $fromPath -> $toPath',
    );
    return true;
  }

  Future<bool> _recoverParent({
    required EncryptedFolder rootFolder,
    required String parentPath,
    required String rootPath,
    required Map<String, EncryptedFolder> lookupTable,
    required Future<EncryptedFolder> Function(String) rescan,
    required bool Function({
      required EncryptedFolder rootFolder,
      required EncryptedFolder newFolder,
    })
    insertFolder,
    required void Function(Map<String, EncryptedFolder>) addToLookup,
  }) async {
    if (!parentPath.startsWith(rootPath)) return false;
    final dir = Directory(parentPath);
    if (!await dir.exists()) return false;

    final recovered = await rescan(parentPath);
    final inserted = insertFolder(rootFolder: rootFolder, newFolder: recovered);
    if (!inserted) return lookupTable.containsKey(parentPath);

    addToLookup(_buildIndex(recovered));
    appLogger.logPageBloc(
      'PrivateFolderDatasource: recovered missing parent $parentPath',
    );
    return true;
  }

  String? _takeMoveSourceCandidate(
    Map<String, DateTime> pendingRemovals,
    String addPath,
  ) {
    if (pendingRemovals.isEmpty) return null;

    final addParent = Directory(addPath).parent.path;
    final addName = addPath.split('/').last;
    final addExt = addName.contains('.') ? addName.split('.').last : '';

    String? bestPath;
    var bestScore = 0;

    for (final oldPath in pendingRemovals.keys) {
      var score = 0;
      final oldParent = Directory(oldPath).parent.path;
      final oldName = oldPath.split('/').last;
      final oldExt = oldName.contains('.') ? oldName.split('.').last : '';

      if (oldParent == addParent) score += 3;
      if (oldName == addName) score += 2;
      if (oldExt.isNotEmpty && oldExt == addExt) score += 1;

      if (score > bestScore) {
        bestScore = score;
        bestPath = oldPath;
      }
    }

    if (bestPath == null || bestScore == 0) return null;
    pendingRemovals.remove(bestPath);
    return bestPath;
  }

  Map<String, EncryptedFolder> _buildIndex(EncryptedFolder root) {
    final map = <String, EncryptedFolder>{};
    void visit(EncryptedFolder folder) {
      map[folder.path] = folder;
      for (final child in folder.subfolders) {
        visit(child);
      }
    }

    visit(root);
    return map;
  }
}
