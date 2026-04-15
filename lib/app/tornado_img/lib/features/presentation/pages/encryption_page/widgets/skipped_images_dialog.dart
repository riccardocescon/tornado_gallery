part of '../encryption_page.dart';

class _SkippedImagesDialog extends StatefulWidget {
  const _SkippedImagesDialog({required this.skippedImages});

  final List<GalleryImage> skippedImages;

  @override
  State<_SkippedImagesDialog> createState() => __SkippedImagesDialogState();
}

class __SkippedImagesDialogState extends State<_SkippedImagesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Images not saved", style: context.textTheme.titleLarge),
      content: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'The following images were not encrypted and saved because the "override" option was disabled and they already exist in the destination folders',
            style: context.textTheme.bodyMedium,
          ),
          SizedBox(
            width: double.maxFinite,
            height: 200,
            child: CarouselView.weighted(
              scrollDirection: Axis.horizontal,
              flexWeights: [2, 1],
              padding: EdgeInsets.zero,
              shrinkExtent: 1,
              itemSnapping: true,
              children:
                  widget.skippedImages
                      .map(
                        (e) => Container(
                          color:
                              widget.skippedImages.indexOf(e) % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.grey[300],
                          child: _skippedImageCard(e),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Close")),
      ],
    );
  }

  Widget _skippedImageCard(GalleryImage image) {
    return SizedBox.expand(child: Image.file(image.file, fit: BoxFit.cover));
  }
}
