import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

/// Flat surface card used by the media detail pages (encrypted image, video
/// player) for their Info / Actions blocks.
///
/// Deliberately not [AppCard]: that one is `surfaceContainerLow` with a drop
/// shadow, this one is a flat [ColorScheme.surface] panel.
class PageBackground extends StatelessWidget {
  const PageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.cardBorderRadius,
      ),
      child: child,
    );
  }
}
