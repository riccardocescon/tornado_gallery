part of '../archive_page.dart';

class _ArchiveFolderTile extends StatelessWidget {
  const _ArchiveFolderTile({
    required this.folder,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onDecrypt,
  });

  final ArchiveFolderView folder;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onDecrypt;

  @override
  Widget build(BuildContext context) {
    final tile = FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: AppStyle.detailsBorderRadius,
        ),
        backgroundColor: context.appColors.scaffoldBackground,
        overlayColor: context.colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: Row(
        spacing: 16,
        children: [
          ContainedItem.icon(icon: Icons.folder_rounded),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${folder.imageCount} ${folder.imageCount == 1 ? "image" : "images"}"
                  "${folder.isPrivate ? "" : " · gallery"}",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                if (folder.isDecrypting)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      spacing: 8,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                (folder.decryptTotal ?? 0) == 0
                                    ? null
                                    : (folder.decryptDone ?? 0) /
                                        folder.decryptTotal!,
                            color: context.colorScheme.primary,
                          ),
                        ),
                        Text(
                          "Decrypting ${folder.decryptDone ?? 0}/${folder.decryptTotal ?? 0}",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        child: FocusedMenuHolder(
          openWithTap: false,
          onPressed: () {},
          menuOffset: 4,
          menuItems: [
            FocusedMenuItem(
              title: Text("Decrypt folder", style: context.textTheme.bodyLarge),
              onPressed: onDecrypt,
              trailingIcon: const Icon(Icons.lock_open_rounded),
            ),
            FocusedMenuItem(
              title: Text("Rename", style: context.textTheme.bodyLarge),
              onPressed: onRename,
              trailingIcon: const Icon(Icons.drive_file_rename_outline),
            ),
            FocusedMenuItem(
              title: Text(
                "Delete",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
              onPressed: onDelete,
              trailingIcon: Icon(
                Icons.delete_rounded,
                color: context.colorScheme.error,
              ),
            ),
          ],
          child: tile,
        ),
      ),
    );
  }
}
