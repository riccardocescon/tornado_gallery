import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';

class CachedImageWidget extends StatefulWidget {
  const CachedImageWidget({
    super.key,
    required this.image,
    required this.onTap,
    required this.index,
    this.currentVisibleRange,
  });

  final GalleryImage image;
  final VoidCallback onTap;
  final int index;
  final ValueNotifier<(int, int)>? currentVisibleRange;

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget>
    with AutomaticKeepAliveClientMixin {
  static const int maxKeepAliveDistance = 8; // Ridotto da 15 a 8 per batteria

  @override
  bool get wantKeepAlive {
    if (widget.currentVisibleRange == null) return true;

    final (start, end) = widget.currentVisibleRange!.value;
    final distance =
        (widget.index < start)
            ? start - widget.index
            : (widget.index > end)
            ? widget.index - end
            : 0; // widget visibile

    return distance <= maxKeepAliveDistance;
  }

  @override
  void initState() {
    super.initState();
    widget.currentVisibleRange?.addListener(_updateKeepAlive);
  }

  @override
  void dispose() {
    widget.currentVisibleRange?.removeListener(_updateKeepAlive);
    super.dispose();
  }

  void _updateKeepAlive() {
    if (mounted) {
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: AppStyle.cardBorderRadius,
        child: Image.file(
          widget.image.file,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          cacheWidth: 150,
          cacheHeight: 150,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  frame != null
                      ? child
                      : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}
