part of '../encrypted_gallery_page.dart';

class _EncryptedImageTile extends StatelessWidget {
  final EncryptedImage image;
  final VoidCallback onTap;

  const _EncryptedImageTile({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bytes = image.decryptedBytes;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: AppStyle.cardBorderRadius,
            child:
                bytes != null
                    ? _DecryptedImageDisplay(bytes: bytes)
                    : Image.file(image.file, fit: BoxFit.cover),
          ),
        ),
        if (image.isDecrypting) _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          strokeWidth: EncryptedGalleryPageConstants.progressIndicatorStroke,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class _DecryptedImageDisplay extends StatelessWidget {
  final Uint8List bytes;

  const _DecryptedImageDisplay({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(bytes, fit: BoxFit.cover),
        _buildDecryptedIndicator(context),
      ],
    );
  }

  Widget _buildDecryptedIndicator(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Transform.rotate(
        angle: 3.14 / 4,
        child: Transform.translate(
          offset: const Offset(40, -30),
          child: Container(
            width: double.maxFinite,
            height: 24,
            color: context.colorScheme.primaryContainer.withValues(alpha: 0.6),
            child: Transform.rotate(
              angle: -3.14 / 4,
              child: Icon(
                Icons.lock_open_rounded,
                color: context.colorScheme.onPrimaryContainer,
                size: EncryptedGalleryPageConstants.decryptIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
