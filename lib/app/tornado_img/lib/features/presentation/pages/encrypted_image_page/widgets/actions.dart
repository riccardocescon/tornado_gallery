part of '../encrypted_image_page.dart';

class _Actions extends StatelessWidget {
  const _Actions({required this.image});

  final EncryptedImage image;

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
        _PageBackground(
          child: Column(
            spacing: 8,
            children: [
              OptionItem.button(
                icon: Icons.save,
                title: "Save picture",
                subtitle:
                    "Save the current state of the picture. Currently this will be stored in the gallery pictures folder.",
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onTap: () {
                  context.read<EncryptedImagePageBloc>().add(
                    const EncryptedImagePageEvent.saveImage(),
                  );
                },
              ),
              OptionItem.button(
                icon: Icons.edit,
                title: "Rename",
                subtitle:
                    "Rename the picture. This will change the name of the file on disk.",
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
                        (_) => BlocProvider.value(
                          value: context.read<EncryptedImagePageBloc>(),
                          child: _RenameBottomSheet(
                            currentName: nameWithoutExtension,
                          ),
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
