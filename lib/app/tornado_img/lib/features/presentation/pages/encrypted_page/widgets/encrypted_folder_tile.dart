part of '../encrypted_gallery_page.dart';

class _EncryptedFolderTile extends StatelessWidget {
  final EncryptedFolder folder;

  const _EncryptedFolderTile({required this.folder});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => _navigateToFolder(context),
      style: _buildButtonStyle(context),
      child: _buildFolderContent(context),
    );
  }

  void _navigateToFolder(BuildContext context) {
    context.push('/encrypted_gallery/${folder.encryptedRelativePath}');
  }

  ButtonStyle _buildButtonStyle(BuildContext context) {
    return FilledButton.styleFrom(
      backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: AppStyle.cardBorderRadius),
    );
  }

  Widget _buildFolderContent(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.folder_rounded,
          color: context.colorScheme.primary,
          size: EncryptedGalleryPageConstants.folderIconSize,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: EncryptedGalleryPageConstants.folderPadding,
            ),
            child: Text(
              folder.name,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
