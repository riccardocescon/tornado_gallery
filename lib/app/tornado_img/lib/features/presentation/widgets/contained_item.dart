import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

class ContainedItem extends StatelessWidget {
  const ContainedItem._({
    required this.icon,
    required this.widget,
    this.size = 24,
    this.backgroundColor,
    this.iconColor,
  });

  factory ContainedItem.icon({
    required IconData icon,
    double size = 24,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return ContainedItem._(
      icon: icon,
      widget: null,
      size: size,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  factory ContainedItem.widget({
    required Widget child,
    double size = 24,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return ContainedItem._(
      icon: null,
      widget: child,
      size: size,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  final IconData? icon;
  final Widget? widget;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.appColors.softBackground,
        borderRadius: AppStyle.detailsBorderRadius,
      ),
      child:
          widget ??
          Icon(
            icon!,
            color: iconColor ?? context.colorScheme.onSurface,
            size: size,
          ),
    );
  }
}
