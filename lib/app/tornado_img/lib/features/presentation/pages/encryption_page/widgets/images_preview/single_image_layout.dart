part of '../../encryption_page.dart';

class _SingleImageLayout extends StatelessWidget {
  const _SingleImageLayout({
    required this.image,
    required this.initSize,
    required this.initDateTime,
    required this.initFileName,
  });

  final GalleryImage image;
  final String initSize;
  final String initDateTime;
  final String initFileName;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        ClipRRect(
          borderRadius: AppStyle.cardBorderRadius,
          child: Stack(
            children: [
              SizedBox.square(
                dimension: 128,
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
        ),
        Expanded(
          child: BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
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
                  size = initSize;
                  dateTime = initDateTime;
                  fileName = initFileName;
                },
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
                  Text(
                    '$size • $dateTime',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
