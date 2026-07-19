part of '../archive_page.dart';

/// The archive top bar. In selection mode it shows the selected count with
/// move/delete actions; otherwise the page title with back / new-folder /
/// import actions. All state lives in the page — this only renders and
/// forwards taps.
class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({
    required this.selectedCount,
    required this.onCancel,
    required this.onMove,
    required this.onDelete,
    required this.onBack,
    required this.onNewFolder,
    required this.onImport,
  });

  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback onBack;
  final VoidCallback onNewFolder;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        final isSelectionMode = state.maybeMap(
          ui: (s) => s.isSelectionMode,
          orElse: () => false,
        );

        if (isSelectionMode) {
          return Row(
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text("Cancel"),
              ),
              const Spacer(),
              Text(
                "$selectedCount selected",
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: selectedCount == 0 ? null : onMove,
                icon: Icon(
                  Icons.drive_file_move_outline,
                  color:
                      selectedCount == 0
                          ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                          : context.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: selectedCount == 0 ? null : onDelete,
                icon: Icon(
                  Icons.delete_rounded,
                  color:
                      selectedCount == 0
                          ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                          : context.colorScheme.error,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageTitle(
                title: "Archive",
                subtitle: "View and manage your archived images",
                icon: Icons.archive,
              ),
            ),
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.drive_folder_upload_rounded),
            ),
            IconButton(
              tooltip: "New folder",
              onPressed: onNewFolder,
              icon: Icon(
                Icons.create_new_folder_outlined,
                color: context.colorScheme.onSurface,
              ),
            ),
            IconButton(
              tooltip: "Import",
              onPressed: onImport,
              icon: Icon(
                Icons.upload_file_rounded,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }
}
