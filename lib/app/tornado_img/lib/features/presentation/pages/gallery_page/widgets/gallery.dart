part of '../gallery_page.dart';

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.scrollController,
    required this.visibleRange,
    required this.onImageSelected,
  });

  final ScrollController scrollController;
  final ValueNotifier<(int, int)> visibleRange;
  final void Function(GalleryImage image) onImageSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryPageBloc, GalleryPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(loaded: (value) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          loaded: (value) {
            return GridView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(8),
              // Ottimizzazioni conservative per batteria
              cacheExtent: 400, // Bilanciato per batteria vs performance
              addRepaintBoundaries: true, // Isola repaint per widget
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: value.images.length,
              itemBuilder: (context, index) {
                final image = value.images[index];
                return CachedImageWidget(
                  key: ValueKey(image.file.path),
                  image: image,
                  index: index,
                  currentVisibleRange: visibleRange,
                  onTap: () => onImageSelected(image),
                );
              },
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
