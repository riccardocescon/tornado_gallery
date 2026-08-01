part of '../video_player_page.dart';

/// Decrypt / restore button + password field + file details. Mirrors the
/// encrypted image page's `_Info`.
class _Info extends StatelessWidget {
  const _Info({
    required this.image,
    required this.isDecrypted,
    required this.decrypting,
    required this.onPasswordChanged,
    required this.onPressed,
  });

  final EncryptedImage image;
  final bool isDecrypted;
  final bool decrypting;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = image.safeSizeBytes;

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

    final created = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(image.safeCreatedAt);

    return PageBackground(
      child: Column(
        spacing: 16,
        children: [
          FilledButton(
            onPressed: decrypting ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: context.appColors.softBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppStyle.cardBorderRadius,
              ),
              overlayColor: context.colorScheme.primary.withValues(alpha: 0.1),
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
                          : Icons.remove_red_eye_rounded,
                      color: context.colorScheme.onSurface,
                      size: 28,
                    ),
                    Text(
                      isDecrypted
                          ? 'Restore Video'
                          : decrypting
                          ? 'Decrypting…'
                          : 'Start Decryption',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  isDecrypted
                      ? 'Tap to restore the original video'
                      : 'Enter the password, then tap to start the process',
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: PasswordFormField(onChanged: onPasswordChanged),
          ),
          Column(
            spacing: 8,
            children: [
              _infoItem(context, 'Name', image.name),
              _infoItem(context, 'Size', sizeText),
              _infoItem(context, 'Created', created),
              _infoItem(context, 'Path', image.storagePath.path),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String title, String value) {
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
