part of '../encryption_page.dart';

class _ImagesPreviewCard extends StatelessWidget {
  const _ImagesPreviewCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (state) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          ui: (value) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerLow,
                borderRadius: AppStyle.cardBorderRadius,
                boxShadow:
                    context.isDarkMode
                        ? null
                        : [
                          BoxShadow(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Column(
                spacing: 12,
                children: [
                  Row(
                    spacing: 16,
                    children: [
                      _image(value.images.first.file),
                      Expanded(
                        child: _fileData(
                          context,
                          value.images.first,
                          value.images.length,
                          value.size,
                          value.dateTime,
                        ),
                      ),
                    ],
                  ),
                  _imagesCompletedCard(),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _image(File file) {
    return ClipRRect(
      borderRadius: AppStyle.cardBorderRadius,
      child: Stack(
        children: [
          SizedBox.square(
            dimension: 128,
            child: Image.file(
              file,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                if (frame == null) {
                  return Container(
                    color: Colors.grey,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return child;
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: ContainedItem.icon(icon: Icons.image_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _fileData(
    BuildContext context,
    GalleryImage previewImage,
    int imagesCount,
    String sizeText,
    String dateText,
  ) {
    final file = previewImage.file;
    final textStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurface.withValues(alpha: 0.4),
    );

    final images = "$imagesCount ${imagesCount > 1 ? 'images' : 'image'}";

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          file.path.split('/').last,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text('$sizeText • $dateText', style: textStyle),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.appColors.softBackground.withValues(alpha: 0.6),
            borderRadius: AppStyle.cardBorderRadius,
          ),
          child: Row(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_rounded, size: 14),
              Text(
                images,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagesCompletedCard() {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      builder: (context, state) {
        return state.maybeMap(
          encrypted: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.appColors.successContainer,
                borderRadius: AppStyle.cardBorderRadius,
              ),
              child: Text(
                'Encprytion completed successfully!',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
