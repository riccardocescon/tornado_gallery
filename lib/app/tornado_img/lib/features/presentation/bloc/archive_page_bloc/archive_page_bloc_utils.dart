part of 'archive_page_bloc.dart';

/// Key identifying a folder by store (private vs gallery) and its path
/// relative to the store root.
typedef FolderKey = ({bool isPrivate, String relativePath});

/// A folder shown at the current navigation level of the Archive page.
class ArchiveFolderView extends Equatable {
  final String name;

  /// Path relative to the store root (e.g. `Vacanze/Mare`).
  final String relativePath;
  final bool isPrivate;

  /// Number of images contained, recursively.
  final int imageCount;

  /// Background-decrypt progress for this folder, or null when no job is running.
  final int? decryptDone;
  final int? decryptTotal;

  bool get isDecrypting => decryptTotal != null;

  const ArchiveFolderView({
    required this.name,
    required this.relativePath,
    required this.isPrivate,
    required this.imageCount,
    this.decryptDone,
    this.decryptTotal,
  });

  @override
  List<Object?> get props => [
    name,
    relativePath,
    isPrivate,
    imageCount,
    decryptDone,
    decryptTotal,
  ];
}

/// Pure helpers that derive the navigable folder tree from a flat image list
/// plus the set of folders created in-session (which may still be empty).
class ArchiveTreeUtils {
  ArchiveTreeUtils._();

  /// Images directly contained at the navigation level identified by
  /// [isPrivate] (null == root, both stores) and [currentPath].
  static List<EncryptedImage> imagesAtLevel(
    List<EncryptedImage> all, {
    required bool? isPrivate,
    required String currentPath,
  }) {
    return all.where((img) {
      if (isPrivate == null) return img.storeRelativeDir.isEmpty;
      return img.storagePath.isPrivateFolder == isPrivate &&
          img.storeRelativeDir == currentPath;
    }).toList();
  }

  /// Every folder that exists in either store, at any depth — the ones implied
  /// by an image's path plus the ones created in-session (which may be empty).
  ///
  /// Intermediate ancestors are included, so an image sitting only in `A/B/C`
  /// still yields `A`, `A/B` and `A/B/C`. This is both the basis of the
  /// navigable tree and the archive count the free-tier cap is checked against.
  static Set<FolderKey> allFolderKeys(
    List<EncryptedImage> all,
    Set<FolderKey> createdFolders,
  ) {
    final allDirs = <FolderKey>{};

    void addWithAncestors(bool priv, String rel) {
      final parts = rel.split('/').where((p) => p.trim().isNotEmpty).toList();
      for (var i = 1; i <= parts.length; i++) {
        allDirs.add((isPrivate: priv, relativePath: parts.take(i).join('/')));
      }
    }

    for (final img in all) {
      final dir = img.storeRelativeDir;
      if (dir.isEmpty) continue;
      addWithAncestors(img.storagePath.isPrivateFolder, dir);
    }
    for (final f in createdFolders) {
      addWithAncestors(f.isPrivate, f.relativePath);
    }

    return allDirs;
  }

  /// Immediate subfolders at the navigation level identified by [isPrivate]
  /// (null == root, both stores) and [currentPath].
  static List<ArchiveFolderView> foldersAtLevel(
    List<EncryptedImage> all,
    Set<FolderKey> createdFolders, {
    required bool? isPrivate,
    required String currentPath,
    DearchivingState? Function(bool isPrivate, String relativePath)? jobFor,
  }) {
    final allDirs = allFolderKeys(all, createdFolders);

    // Select the immediate children of the current level.
    final children = <String, FolderKey>{}; // dedup key -> child
    for (final dir in allDirs) {
      if (isPrivate != null && dir.isPrivate != isPrivate) continue;

      final String childRel;
      if (currentPath.isEmpty) {
        childRel = dir.relativePath.split('/').first;
      } else {
        if (!dir.relativePath.startsWith('$currentPath/')) continue;
        final next =
            dir.relativePath.substring(currentPath.length + 1).split('/').first;
        childRel = '$currentPath/$next';
      }
      final key = '${dir.isPrivate ? 'P' : 'G'}:$childRel';
      children[key] = (isPrivate: dir.isPrivate, relativePath: childRel);
    }

    final views =
        children.values.map((child) {
            final count =
                all.where((img) {
                  if (img.storagePath.isPrivateFolder != child.isPrivate) {
                    return false;
                  }
                  final d = img.storeRelativeDir;
                  return d == child.relativePath ||
                      d.startsWith('${child.relativePath}/');
                }).length;
            final job = jobFor?.call(child.isPrivate, child.relativePath);
            return ArchiveFolderView(
              name: child.relativePath.split('/').last,
              relativePath: child.relativePath,
              isPrivate: child.isPrivate,
              imageCount: count,
              decryptDone: job?.progress,
              decryptTotal: job?.totalImages,
            );
          }).toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return views;
  }

  /// All images contained under [relativePath] in the given store, recursively.
  static List<EncryptedImage> imagesUnder(
    List<EncryptedImage> all, {
    required bool isPrivate,
    required String relativePath,
  }) {
    return all.where((img) {
      if (img.storagePath.isPrivateFolder != isPrivate) return false;
      final d = img.storeRelativeDir;
      if (relativePath.isEmpty) return true;
      return d == relativePath || d.startsWith('$relativePath/');
    }).toList();
  }
}
