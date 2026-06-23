part of '../archive_page.dart';

/// Bottom sheet that lists every folder in the given store so the user can
/// pick a destination for the selected images. Pops the chosen folder's
/// relative path ('' for the root).
class _MoveTargetSheet extends StatelessWidget {
  const _MoveTargetSheet({
    required this.allImages,
    required this.isPrivate,
    this.extraFolders = const [],
  });

  final List<EncryptedImage> allImages;
  final bool isPrivate;

  /// Pre-computed folder relative paths from the bloc's created-folder set.
  /// Used on iOS where public images don't carry nested paths.
  final List<String> extraFolders;

  List<String> _folderPaths() {
    final paths = <String>{};
    for (final img in allImages) {
      if (img.storagePath.isPrivateFolder != isPrivate) continue;
      final dir = img.storeRelativeDir;
      if (dir.isEmpty) continue;
      final parts = dir.split('/');
      for (var i = 1; i <= parts.length; i++) {
        paths.add(parts.take(i).join('/'));
      }
    }
    for (final rel in extraFolders) {
      final parts = rel.split('/');
      for (var i = 1; i <= parts.length; i++) {
        paths.add(parts.take(i).join('/'));
      }
    }
    final sorted = paths.toList()..sort();
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final folders = _folderPaths();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Move to",
                style: context.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_rounded),
                    title: const Text("Root"),
                    onTap: () => Navigator.pop(context, ''),
                  ),
                  ...folders.map(
                    (path) => ListTile(
                      leading: const Icon(Icons.folder_rounded),
                      title: Text(path),
                      onTap: () => Navigator.pop(context, path),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
