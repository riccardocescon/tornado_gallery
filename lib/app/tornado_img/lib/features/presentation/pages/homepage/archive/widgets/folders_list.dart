part of '../archive_page.dart';

/// The sliver list of subfolders at the current level. Folder actions are
/// forwarded to the page (which owns the dialogs/sheets they open).
class _FoldersList extends StatelessWidget {
  const _FoldersList({
    required this.onEnter,
    required this.onRename,
    required this.onDelete,
    required this.onDecrypt,
  });

  final ValueChanged<ArchiveFolderView> onEnter;
  final ValueChanged<ArchiveFolderView> onRename;
  final ValueChanged<ArchiveFolderView> onDelete;
  final ValueChanged<ArchiveFolderView> onDecrypt;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        final folders = state.maybeMap(
          ui: (s) => s.folders,
          orElse: () => <ArchiveFolderView>[],
        );
        if (folders.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverList.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return _ArchiveFolderTile(
              folder: folder,
              onTap: () => onEnter(folder),
              onRename: () => onRename(folder),
              onDelete: () => onDelete(folder),
              onDecrypt: () => onDecrypt(folder),
            );
          },
        );
      },
    );
  }
}
