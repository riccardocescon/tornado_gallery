import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

/// The standard surface card used across the encryption page: a rounded
/// [Container] on [ColorScheme.surfaceContainerLow] with a soft drop shadow in
/// light mode (no shadow in dark mode).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        boxShadow:
            context.isDarkMode
                ? null
                : [
                  BoxShadow(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: child,
    );
  }
}
