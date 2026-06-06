part of '../encrypted_image_page.dart';

class _Info extends StatefulWidget {
  const _Info({required this.image});

  final EncryptedImage image;

  @override
  State<_Info> createState() => _InfoState();
}

class _InfoState extends State<_Info> {
  @override
  Widget build(BuildContext context) {
    final size = widget.image.safeSizeBytes;
    final createdAt = widget.image.safeCreatedAt;

    String sizeText;
    if (size < 1024) {
      sizeText = '$size bytes';
    } else if (size < 1024 * 1024) {
      sizeText = '${(size / 1024).toStringAsFixed(2)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      sizeText = '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      sizeText = '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    final created = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    return _PageBackground(
      child: Column(
        spacing: 16,
        children: [
          BlocBuilder<EncryptedImagePageBloc, EncryptedImagePageState>(
            buildWhen:
                (previous, current) =>
                    current.maybeMap(ui: (value) => true, orElse: () => false),
            builder: (context, state) {
              final image = state.maybeMap(
                ui: (value) => value.image,
                orElse: () => widget.image,
              );

              final isDecrypted = image.decryptInfo != null;

              return FilledButton(
                onPressed: () {
                  if (isDecrypted) {
                    context.read<EncryptedImagePageBloc>().add(
                      const EncryptedImagePageEvent.restore(),
                    );
                    return;
                  }

                  context.read<EncryptedImagePageBloc>().add(
                    const EncryptedImagePageEvent.decrypt(),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.appColors.softBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyle.cardBorderRadius,
                  ),
                  overlayColor: context.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                ),
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Icon(
                          isDecrypted
                              ? Icons.restore_rounded
                              :
                          Icons.remove_red_eye_rounded,
                          color: context.colorScheme.onSurface,
                          size: 28,
                        ),
                        Text(
                          isDecrypted ? 'Restore Image' : 'Start Decryption',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isDecrypted
                          ? 'Tap to restore the original image'
                          : 'Enter the password, then tap to start the process',
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 48,
            child: PasswordFormField(
              onChanged: (value) {
                context.read<EncryptedImagePageBloc>().add(
                  EncryptedImagePageEvent.updatePassword(value),
                );
              },
            ),
          ),
          Column(
            spacing: 8,
            children: [
              _infoItem('Name', widget.image.name),
              _infoItem('Size', sizeText),
              _infoItem('Created', created),
              _infoItem('Path', widget.image.storagePath.path),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
