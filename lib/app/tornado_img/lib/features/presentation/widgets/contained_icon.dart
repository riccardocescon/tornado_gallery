import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

class ContainedIcon extends StatelessWidget {
  const ContainedIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
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
      child: Icon(
        icon,
        color: iconColor ?? context.colorScheme.onSurface,
        size: size,
      ),
    );
  }
}
