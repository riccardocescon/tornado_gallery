part of '../../encryption_page.dart';

class _MultiImagesLayout extends StatefulWidget {
  const _MultiImagesLayout({
    required this.images,
    required this.initSize,
    required this.initDateTime,
    required this.initFileName,
  });

  final List<GalleryImage> images;
  final String initSize;
  final String initDateTime;
  final String initFileName;

  @override
  State<_MultiImagesLayout> createState() => _MultiImagesLayoutState();
}

class _MultiImagesLayoutState extends State<_MultiImagesLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Primary slot has weight 3 out of total 6, so it takes half the width.
        // Each item occupies that same half-width when it was in the primary slot,
        // so snapped scroll offsets are spaced by this value.
        final itemWidth = constraints.maxWidth / 2;
        return Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                final index = (notification.metrics.pixels / itemWidth)
                    .round()
                    .clamp(0, widget.images.length - 1);
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                  context.read<EncryptionPageBloc>().add(
                    EncryptionPageEvent.selectImage(index: index),
                  );
                }
                return false;
              },
              child: SizedBox(
                height: 128,
                child: CarouselView.weightedBuilder(
                  flexWeights: const [3, 2, 1],
                  itemCount: widget.images.length,
                  itemSnapping: true,
                  itemBuilder: (context, index) {
                    final image = widget.images[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ClipRRect(
                        borderRadius: AppStyle.cardBorderRadius,
                        child: Image.file(
                          image.file,
                          fit: BoxFit.cover,
                          frameBuilder: (
                            context,
                            child,
                            frame,
                            wasSynchronouslyLoaded,
                          ) {
                            if (wasSynchronouslyLoaded) return child;
                            if (frame == null) {
                              return Container(
                                color: Colors.grey,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                    );
                  },
                ),
              ),
            ),
            _buildFileData(context),
          ],
        );
      },
    );
  }

  Widget _buildFileData(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        late String size;
        late String dateTime;
        late String fileName;

        state.maybeMap(
          ui: (value) {
            size = value.size;
            dateTime = value.dateTime;
            fileName = value.fileName;
          },

          orElse: () {
            size = widget.initSize;
            dateTime = widget.initDateTime;
            fileName = widget.initFileName;
          },
        );

        final textStyle = context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.4),
        );
        return Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$size • $dateTime', style: textStyle),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.softBackground.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: AppStyle.cardBorderRadius,
                  ),
                  child: Row(
                    spacing: 6,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_rounded, size: 14),
                      Text(
                        '${_currentIndex + 1} / ${widget.images.length} images',
                        style: context.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
