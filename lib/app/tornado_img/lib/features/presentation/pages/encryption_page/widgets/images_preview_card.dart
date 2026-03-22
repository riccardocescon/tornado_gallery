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
                boxShadow: [
                  BoxShadow(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                spacing: 16,
                children: [
                  _image(value.images.first.file),
                  Expanded(child: _fileData(context, value.images)),
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
          FutureBuilder(
            future: file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingContainer(width: 128, height: 128);
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Container(
                  width: 128,
                  height: 128,
                  color: context.colorScheme.errorContainer,
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: context.colorScheme.onErrorContainer,
                    size: 32,
                  ),
                );
              }

              return SizedBox.square(
                dimension: 128,
                child: Image.memory(snapshot.data!, fit: BoxFit.cover),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: ContainedIcon(icon: Icons.image_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _fileData(BuildContext context, List<GalleryImage> files) {
    final file = files.first.file;
    final textStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurface.withValues(alpha: 0.4),
    );

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          file.path.split('/').last,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            FutureBuilder(
              future: file.length(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingContainer(width: 40, height: 12);
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Text('Unknown size', style: textStyle);
                }

                final size = snapshot.data!;
                String sizeText;
                if (size < 1024 * 1024) {
                  final sizeInKB = size / 1024;
                  sizeText = '${sizeInKB.toStringAsFixed(2)} KB';
                } else {
                  final sizeInMB = size / (1024 * 1024);
                  sizeText = '${sizeInMB.toStringAsFixed(2)} MB';
                }
                return Text(sizeText, style: textStyle);
              },
            ),
            Text(' • ', style: textStyle),
            FutureBuilder(
              future: file.lastModified(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingContainer(width: 80, height: 12);
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Text('Unknown date', style: textStyle);
                }

                final date = snapshot.data!;
                final formattedDate = DateFormat("dd MMM yyyy").format(date);
                return Text(formattedDate, style: textStyle);
              },
            ),
          ],
        ),
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
                "${files.length} ${files.length > 1 ? 'images' : 'image'}",
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
}
