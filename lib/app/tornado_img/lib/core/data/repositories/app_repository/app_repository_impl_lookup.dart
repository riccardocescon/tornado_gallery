part of 'app_repository_impl.dart';

/// Pure in-memory tree helpers used by [AppRepositoryImpl].
///
/// All methods here operate only on [_lookupTable] and the [EncryptedFolder]
/// tree — no I/O, no platform code. Extracted as a `part` to keep the main
/// repository file focused on orchestration.
extension _AppRepositoryLookup on AppRepositoryImpl {
  // ── Lookup table ────────────────────────────────────────────────────────────

  /// Builds a flat path → folder map for [root] and all its descendants.
  Map<String, EncryptedFolder> _buildIndex(EncryptedFolder root) {
    final map = <String, EncryptedFolder>{};
    void visit(EncryptedFolder folder) {
      map[folder.path] = folder;
      for (final child in folder.subfolders) visit(child);
    }
    visit(root);
    return map;
  }

  /// Removes [rootPath] and all descendant paths from [_lookupTable].
  void _removeLookupBranch(String rootPath) {
    final prefix = '$rootPath/';
    _lookupTable.removeWhere(
      (k, _) => k == rootPath || k.startsWith(prefix),
    );
  }

  // ── Tree mutation ───────────────────────────────────────────────────────────

  /// Inserts [newFolder] under its parent in the tree rooted at [rootFolder].
  ///
  /// Returns true if the folder was inserted, false if the parent was not
  /// found or the folder already exists.
  bool _insertFolder({
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

    final alreadyExists = parent.subfolders.any((f) => f.path == newFolder.path);
    if (alreadyExists) return false;

    parent.subfolders.add(newFolder);
    return true;
  }

  /// Recursively removes [toRemove] from the subtree rooted at [root].
  ///
  /// Returns true if the folder was found and removed.
  bool _removeFolderFromTree(EncryptedFolder root, EncryptedFolder toRemove) {
    final found = root.subfolders.firstWhereOrNull(
      (f) => f.path == toRemove.path,
    );

    if (found != null) {
      root.subfolders.remove(found);
      return true;
    }

    for (final sub in root.subfolders) {
      if (_removeFolderFromTree(sub, toRemove)) return true;
    }

    return false;
  }
}
