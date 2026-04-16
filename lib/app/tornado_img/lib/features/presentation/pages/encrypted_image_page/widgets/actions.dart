part of '../encrypted_image_page.dart';

class _Actions extends StatelessWidget {
  const _Actions();

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
            ],
          ),
        ),
      ],
    );
  }
}
