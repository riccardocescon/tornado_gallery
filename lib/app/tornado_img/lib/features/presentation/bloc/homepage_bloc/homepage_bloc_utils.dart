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

Future<List<GalleryImage>> mapAssetsToGalleryImages(
    List<AssetEntity> assets,
  ) async {
    final List<GalleryImage> images = [];

    for (final asset in assets) {
    try {
        final file = await asset.file;
        if (file == null) continue;

        images.add(
          GalleryImage(id: asset.id, file: file, date: asset.createDateTime),
        );
      } catch (e) {
        appLogger.logPageBloc(
          'Error mapping asset to GalleryImage',
          error: e.toString(),
        );
      }
    }

    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
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
      appLogger.logPageBloc("Received file system event: ${event.toString()}");
      final isDirectory =
          event.isDirectory || !event.path.split('/').last.contains('.');
      if (isDirectory) {
        if (event.type == FileSystemEvent.delete) {
          final folder = _lookupTable[event.path];
          if (folder != null) {
            _removeEncryptedFolder(rootFolder, folder);
            _lookupTable.remove(event.path);
          }
          appLogger.logPageBloc(
            'Folder deleted: ${event.path}, removed from lookup',
          );
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
          appLogger.logPageBloc(
            'Failed to insert folder',
            error: 'Path: ${event.path}',
          );
        }
        continue;
      }

      if (event.type == FileSystemEvent.delete) {
        final fileName = event.path.split('/').last;
        final parentPath = Directory(event.path).parent.path;
        final parentFolder = _lookupTable[parentPath];
        if (parentFolder != null) {
          parentFolder.images.removeWhere((img) => img.id == fileName);
          appLogger.logPageBloc(
            'File deleted: ${event.path}, removed from parent folder in lookup',
          );
        } else {
          appLogger.logPageBloc(
            'Failed to delete file',
            error: 'Parent folder not found in lookup for path: ${event.path}',
          );
        }
        yield null;
        continue;
      }

      final parentPath = Directory(event.path).parent.path;
      final parentFolder = _lookupTable[parentPath];
      if (parentFolder == null) {
        appLogger.logPageBloc(
          'Failed to add new file',
          error: 'Parent folder not found in lookup for path: ${event.path}',
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
