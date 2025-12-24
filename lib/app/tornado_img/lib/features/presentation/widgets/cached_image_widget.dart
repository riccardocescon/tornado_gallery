import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class CachedImageWidget extends StatefulWidget {
  const CachedImageWidget({
    super.key,
    required this.image,
    required this.onTap,
  });

  final GalleryImage image;
  final VoidCallback onTap;

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: AppStyle.borderRadius,
        child: Image.file(widget.image.file, fit: BoxFit.cover),
      ),
    );
  }
}
