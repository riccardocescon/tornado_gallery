part of 'app_repository_impl.dart';

extension AppRepositoryImplUtils on AppRepositoryImpl {
  /// Scans the given folder path and returns an EncryptedFolder containing all images and subfolders.
  Future<EncryptedFolder> _scanFullFolderPrivate(String path) async {
    final rootFolder = EncryptedFolder.empty(path, true);

    final files = Directory(rootFolder.path).listSync();
    for (final fileSystem in files) {
      final fileName = fileSystem.path.split('/').last;
      if (fileName.contains('.')) {
        final date = fileSystem.statSync().modified;
        final bytes = await File(fileSystem.path).readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        rootFolder.images.add(
          EncryptedImage(
            storagePath: StoragePath(
              path: fileSystem.path,
              isPrivateFolder: true,
              assetId: null,
            ),
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: date,
          ),
        );
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path, true);
        rootFolder.subfolders.add(subfolder);
      }
    }

    return rootFolder;
  }

  /// Recursively loads a folder and its subfolders, returning an EncryptedFolder with all images and subfolders.
  /// If any error occurs while loading a folder, it logs the error and returns an empty folder for that path.
  Future<EncryptedFolder> _loadSubfolder(
    String path,
    bool isPrivateFolder,
  ) async {
    try {
      final folder = EncryptedFolder.empty(path, isPrivateFolder);
      final files = Directory(path).listSync();
      for (final fileSystem in files) {
        final fileName = fileSystem.path.split('/').last;
        if (fileName.contains('.')) {
          final date = fileSystem.statSync().modified;
          final bytes = await File(fileSystem.path).readAsBytes();
          final hash = ByteModeling.generateHash(bytes);
          folder.images.add(
            EncryptedImage(
              storagePath: StoragePath(
                path: fileSystem.path,
                isPrivateFolder: isPrivateFolder,
                assetId: null,
              ),
              encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
              date: date,
            ),
          );
        } else {
          final subfolder = await _loadSubfolder(
            fileSystem.path,
            isPrivateFolder,
          );
          folder.subfolders.add(subfolder);
        }
      }
      return folder;
    } catch (e) {
      appLogger.logRepository(
        'Error loading subfolder at $path',
        error: e.toString(),
      );

      if (kDebugMode) {
        log(
          "---------------- DELETING BAD CREATED FOLDER: $path ----------------",
        );
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      return EncryptedFolder.empty(path, isPrivateFolder);
    }
  }

  /// Adds all the given [assets] to the [rootFolder] by reading their bytes and metadata, and returns the updated [EncryptedFolder].
  Future<EncryptedFolder> _scanFullFolderPublic(
    List<AssetEntity> assets,
  ) async {
    final firstFile = await assets.first.file;
    final absoluteFolderPath =
        await GalleryPathProvider.getPublicFolderPath() ??
        firstFile?.parent.path ??
        assets.first.relativePath ??
        'Pictures/TornadoGallery';
    final rootFolder = EncryptedFolder.empty(absoluteFolderPath, false);

    for (final asset in assets) {
      try {
        final file = await asset.file;
        if (file == null) continue;

        final bytes = await file.readAsBytes();
        final hash = ByteModeling.generateHash(bytes);
        final storagePath = await getPublicFolderAssetPath(
          asset: asset,
          absoluteFolderPath: absoluteFolderPath,
          hash: hash,
          filePath: file.path,
        );

        rootFolder.images.add(
          EncryptedImage(
            storagePath: StoragePath(
              path: storagePath,
              isPrivateFolder: false,
              assetId: asset.id,
            ),
            encryptedInfo: BytesInfo(bytes: bytes, hash: hash),
            date: asset.createDateTime,
          ),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error loading public image ${asset.id}',
          error: e.toString(),
        );
      }
    }

    return rootFolder;
  }

  /// Recursively searches for the folder to remove in the [root] and removes it if found.
  /// Returns true if the folder was found and removed, false otherwise.
  bool _removeEncryptedFolder(EncryptedFolder root, EncryptedFolder toRemove) {
    final folder = root.subfolders.firstWhereOrNull(
      (folder) => folder.path == toRemove.path,
    );

    if (folder != null) {
      root.subfolders.remove(folder);
      return true;
    }

    for (final sub in root.subfolders) {
      if (_removeEncryptedFolder(sub, toRemove)) {
        return true;
      }
    }

    return false;
  }

  /// Applies the removal of a folder or image at the given path from the [rootFolder] and the lookup table.
  /// Returns true if a folder or image was found and removed, false otherwise.
  bool _applyRemovePath(EncryptedFolder rootFolder, String path) {
    final folder = _lookupTable[path];
    if (folder != null) {
      _removeEncryptedFolder(rootFolder, folder);
      _removeLookupBranch(path);
      appLogger.logPageBloc('Folder deleted: $path, removed from lookup');
      return true;
    }

    final parentPath = Directory(path).parent.path;
    final parentFolder = _lookupTable[parentPath];
    if (parentFolder != null) {
      final hadImage = parentFolder.images.any(
        (img) => img.storagePath.path == path,
      );
      if (hadImage) {
        parentFolder.images.removeWhere((img) => img.storagePath.path == path);
        appLogger.logPageBloc(
          'File deleted: $path, removed from parent folder in lookup',
        );
        return true;
      }
    }

    appLogger.logPageBloc(
      'Failed to delete item',
      error: 'Path not found in lookup: $path',
    );
    return false;
  }

  /// Applies the move/rename of a folder or image from [fromPath] to [toPath] in the [rootFolder] and the lookup table.
  /// Returns true if a folder or image was found and moved, false otherwise.
  /// This method handles both folder moves/renames and image moves/renames,
  /// and also handles the case where a folder is moved into a new parent
  /// that is not yet in the lookup (by attempting to recover the missing parent).
  Future<bool> _applyMovePath({
    required EncryptedFolder rootFolder,
    required String fromPath,
    required String toPath,
    required String rootPath,
  }) async {
    final movedFolder = _lookupTable[fromPath];
    if (movedFolder != null) {
      _removeEncryptedFolder(rootFolder, movedFolder);
      _removeLookupBranch(fromPath);

      final rescanned = await _scanFullFolderPrivate(toPath);
      final inserted = insertFolderFast(
        rootFolder: rootFolder,
        newFolder: rescanned,
      );
      if (!inserted) return false;

      _lookupTable.addAll(_buildFolderIndex(rescanned));
      appLogger.logPageBloc('Folder moved/renamed: $fromPath -> $toPath');
      return true;
    }

    final fromParentPath = Directory(fromPath).parent.path;
    final toParentPath = Directory(toPath).parent.path;
    final fromParent = _lookupTable[fromParentPath];
    if (fromParent == null) return false;

    EncryptedFolder? toParent = _lookupTable[toParentPath];
    if (toParent == null) {
      final recovered = await _recoverMissingParentFolder(
        rootFolder: rootFolder,
        parentPath: toParentPath,
        rootPath: rootPath,
      );
      if (recovered) {
        toParent = _lookupTable[toParentPath];
      }
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
    appLogger.logPageBloc('File moved/renamed: $fromPath -> $toPath');
    return true;
  }

  /// Recursively searches for the missing parent folder at [parentPath] starting from the [rootFolder],
  /// and if found, adds it to the lookup table.
  void _removeLookupBranch(String rootPath) {
    final prefix = '$rootPath/';
    final keysToRemove =
        _lookupTable.keys
            .where((k) => k == rootPath || k.startsWith(prefix))
            .toList();
    for (final key in keysToRemove) {
      _lookupTable.remove(key);
    }
  }

  /// Builds a lookup map of folder paths to EncryptedFolder objects for all folders in the tree starting from [root].
  /// This is used to efficiently find folders by path when applying moves and deletions.
  /// The map includes the root folder and all of its subfolders, indexed by their absolute paths.
  Map<String, EncryptedFolder> _buildFolderIndex(EncryptedFolder root) {
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

  /// Recursively searches for the missing parent folder at [parentPath] starting from the [rootFolder],
  /// and if found, adds it to the lookup table and returns true. If not found, returns false.
  bool insertFolderFast({
    required EncryptedFolder rootFolder,
    required EncryptedFolder newFolder,
  }) {
    final parentPath = Directory(newFolder.path).parent.path;

    EncryptedFolder? findParent(EncryptedFolder folder) {
      if (folder.path == parentPath) return folder;
      for (final sub in folder.subfolders) {
        final found = findParent(sub);
        if (found != null) return found;
      }
      return null;
    }

    final parent = findParent(rootFolder);
    if (parent == null) return false;

    final alreadyExists = parent.subfolders.any(
      (f) => f.path == newFolder.path,
    );
    if (alreadyExists) return false;

    parent.subfolders.add(newFolder);
    return true;
  }

  /// Recursively searches for the missing parent folder at [parentPath] starting from the [rootFolder],
  /// and if found, adds it to the lookup table and returns true. If not found, returns false.
  Future<bool> _recoverMissingParentFolder({
    required EncryptedFolder rootFolder,
    required String parentPath,
    required String rootPath,
  }) async {
    // Watchers can emit file ADD before folder ADD. Rebuild and insert the
    // missing parent so the file event can be processed in the same tick.
    if (!parentPath.startsWith(rootPath)) return false;

    final dir = Directory(parentPath);
    if (!await dir.exists()) return false;

    final recoveredFolder = await _scanFullFolderPrivate(parentPath);
    final inserted = insertFolderFast(
      rootFolder: rootFolder,
      newFolder: recoveredFolder,
    );

    if (!inserted) {
      return _lookupTable.containsKey(parentPath);
    }

    _lookupTable.addAll(_buildFolderIndex(recoveredFolder));
    appLogger.logPageBloc(
      'Recovered missing parent folder in lookup: $parentPath',
    );
    return true;
  }

  /// Recursively searches for the image to remove in the [root] and removes it if found.
  /// Returns true if the image was found and removed, false otherwise.
  /// This method is used to handle the case where an image is deleted and then re-added within a short time frame, to prevent flickering in the UI.
  /// (This happens when renaming a file on iOS on the public folder, since no rename API is available)
  bool _flushExpiredRemovals({
    required EncryptedFolder rootFolder,
    required Map<String, DateTime> pendingRemovals,
    required Duration window,
  }) {
    final now = DateTime.now();
    final expired =
        pendingRemovals.entries
            .where((entry) => now.difference(entry.value) >= window)
            .map((entry) => entry.key)
            .toList();

    var changed = false;
    for (final path in expired) {
      pendingRemovals.remove(path);
      changed = _applyRemovePath(rootFolder, path) || changed;
    }
    return changed;
  }

  /// Recursively searches for the given path in the [root] and removes the corresponding folder or image if found.
  /// Returns true if a folder or image was found and removed, false otherwise.
  /// This method is used to handle the case where an image is deleted and then re-added within a short time frame, to prevent flickering in the UI.
  /// (This happens when renaming a file on iOS on the public folder, since no rename API is available)
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
}
