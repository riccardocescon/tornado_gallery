part of 'homepage_bloc.dart';

@visibleForTesting
class HomepageBlocUtils {
  final _lookupTable = <String, EncryptedFolder>{};
  // Future<List<EncryptedEntity>> loadLatestEncryptedImages({
  //   int limit = 3,
  // }) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final encryptedDir = Directory('${dir.path}/encrypted');

  //     if (!await encryptedDir.exists()) {
  //       return [];
  //     }

  //     final files =
  //         encryptedDir.listSync().take(limit).toList()..sort(
  //           (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
  //         );

  //     final encryptedImages = <EncryptedEntity>[];
  //     for (final fileSystem in files) {
  //       final fileName = fileSystem.path.split('/').last;
  //       if (fileName.contains('.')) {
  //         final file = File(fileSystem.path);
  //         final date = fileSystem.statSync().modified;
  //         encryptedImages.add(
  //           EncryptedImage(id: fileName, file: file, date: date),
  //         );
  //       } else {
  //         encryptedImages.add(EncryptedFolder.empty(fileSystem.path));
  //       }
  //     }

  //     return encryptedImages;
  //   } catch (e) {
  //     log('Error loading encrypted images: $e');
  //     return [];
  //   }
  // }

  Future<AssetEntity?> findSavedImageByName(String name) async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false, // false = descending (newest first)
            ),
          ],
        ),
      );

      if (albums.isEmpty) return null;

      final assetsCount = await albums.first.assetCountAsync;
      const int searchPageSize = 100;

      log(
        'Searching for "$name" in $assetsCount total assets (starting from most recent)',
      );

      // Calculate total pages
      final totalPages = (assetsCount / searchPageSize).ceil();

      // Start from the LAST page (most recent) and work backwards
      for (int page = totalPages - 1; page >= 0; page--) {
        final recentAssets = await albums.first.getAssetListPaged(
          page: page,
          size: searchPageSize,
        );

        // Early termination if no more assets
        if (recentAssets.isEmpty) {
          log('No more assets found at page $page, stopping search');
          continue;
        }

        // Search within this page (reverse order to get most recent first)
        for (int i = recentAssets.length - 1; i >= 0; i--) {
          try {
            final asset = recentAssets[i];
            final title = await asset.titleAsync;
            if (title == name) {
              log(
                'Found matching asset: $title at page $page (${totalPages - page} pages from end)',
              );
              return asset;
            }
          } catch (e) {
            // Continue if single asset fails
            log('Error getting title for asset: $e');
          }
        }

        log(
          'Searched page $page (${recentAssets.length} assets) - ${totalPages - page} pages from end',
        );

        // Early exit after searching reasonable number of recent pages
        if ((totalPages - page) > 10) {
          log(
            'Searched 10 most recent pages without success, stopping for performance',
          );
          break;
        }
      }

      log('Image "$name" not found in recent assets');
      return null;
    } catch (e) {
      log('Error in _findSavedImageByName: $e');
      return null;
    }
  }

  Future<EncryptedFolder> loadAppRootFolder() async {
    final appPath = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appPath.path}/encrypted');
    final encryptedExists = await encryptedDir.exists();
    if (!encryptedExists) {
      await encryptedDir.create(recursive: true);
    }

    final rootFolder = await _scanFullFolder(encryptedDir.path);
    _lookupTable.addAll(_buildFolderIndex(rootFolder));
    return rootFolder;
  }

  Future<EncryptedFolder> _loadSubfolder(String path) async {
    final folder = EncryptedFolder.empty(path);
    final files = Directory(path).listSync();
    for (final fileSystem in files) {
      final fileName = fileSystem.path.split('/').last;
      if (fileName.contains('.')) {
        final file = File(fileSystem.path);
        final date = fileSystem.statSync().modified;
        folder.images.add(EncryptedImage(id: fileName, file: file, date: date));
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path);
        folder.subfolders.add(subfolder);
      }
    }
    return folder;
  }

  Future<EncryptedFolder> _scanFullFolder(String path) async {
    final rootFolder = EncryptedFolder.empty(path);

    final files = Directory(rootFolder.path).listSync();
    for (final fileSystem in files) {
      final fileName = fileSystem.path.split('/').last;
      if (fileName.contains('.')) {
        final file = File(fileSystem.path);
        final date = fileSystem.statSync().modified;
        rootFolder.images.add(
          EncryptedImage(id: fileName, file: file, date: date),
        );
      } else {
        final subfolder = await _loadSubfolder(fileSystem.path);
        rootFolder.subfolders.add(subfolder);
      }
    }

    return rootFolder;
  }

  Stream<void> watchAppFolderChanges(EncryptedFolder rootFolder) async* {
    final appPath = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appPath.path}/encrypted');
    final folderStream = encryptedDir.watch(
      events: FileSystemEvent.create | FileSystemEvent.delete,
      recursive: true,
    );

    await for (final event in folderStream) {
      log("Received file system event: ${event.toString()}");
      final isDirectory =
          event.isDirectory || !event.path.split('/').last.contains('.');
      if (isDirectory) {
        if (event.type == FileSystemEvent.delete) {
          final folder = _lookupTable[event.path];
          if (folder != null) {
            _removeEncryptedFolder(rootFolder, folder);
            _lookupTable.remove(event.path);
          }
          log('Folder deleted: ${event.path}, removed from lookup');
          yield null;
          continue;
        }

        final newFolder = await _scanFullFolder(event.path);

        final inserted = insertFolderFast(
          rootFolder: rootFolder,
          newFolder: newFolder,
        );

        if (inserted) {
          yield null;
        } else {
          log('[ERROR]: Failed to insert folder for path: ${event.path}');
        }
        continue;
      }

      if (event.type == FileSystemEvent.delete) {
        final fileName = event.path.split('/').last;
        final parentPath = Directory(event.path).parent.path;
        final parentFolder = _lookupTable[parentPath];
        if (parentFolder != null) {
          parentFolder.images.removeWhere((img) => img.id == fileName);
          log(
            'File deleted: ${event.path}, removed from parent folder in lookup',
          );
        } else {
          log(
            '[ERROR]: Parent folder not found in lookup for deleted file path: ${event.path}',
          );
        }
        yield null;
        continue;
      }

      final parentPath = Directory(event.path).parent.path;
      final parentFolder = _lookupTable[parentPath];
      if (parentFolder == null) {
        log(
          '[ERROR]: Parent folder not found in lookup for path: ${event.path}',
        );
        continue;
      }

      final fileName = event.path.split('/').last;
      final file = File(event.path);
      final date = file.statSync().modified;
      final newImage = EncryptedImage(id: fileName, file: file, date: date);

      parentFolder.images.removeWhere((img) => img.id == fileName);
      parentFolder.images.add(newImage);
      yield null;
    }
  }

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

  /// Inserisce newFolder nell'albero rootFolder, navigando direttamente senza usare foldersByPath.
  bool insertFolderFast({
    required EncryptedFolder rootFolder,
    required EncryptedFolder newFolder,
  }) {
    final parentPath = Directory(newFolder.path).parent.path;

    // Naviga ricorsivamente per trovare il parent
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

    // Controlla se già esiste
    final alreadyExists = parent.subfolders.any(
      (f) => f.path == newFolder.path,
    );
    if (alreadyExists) return false;

    parent.subfolders.add(newFolder);
    return true;
  }
}
