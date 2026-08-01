part of '../video_player_page.dart';

/// Save / rename, same card and copy as the encrypted image page's `_Actions`.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.image,
    required this.onSave,
    required this.onRename,
  });

  final EncryptedImage image;
  final VoidCallback onSave;
  final ValueChanged<String> onRename;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actions",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        PageBackground(
          child: Column(
            spacing: 8,
            children: [
              OptionItem.button(
                icon: Icons.save,
                title: "Save video",
                subtitle:
                    "Save the current state of the video. Currently this will be stored in the gallery videos folder.",
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onTap: onSave,
              ),
              OptionItem.button(
                icon: Icons.edit,
                title: "Rename",
                subtitle:
                    "Rename the video. This will change the name of the file on disk.",
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onTap: () {
                  final nameWithoutExtension = image.name.split('.').first;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder:
                        (_) => RenameBottomSheet(
                          title: 'Rename video',
                          currentName: nameWithoutExtension,
                          onRename: onRename,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
