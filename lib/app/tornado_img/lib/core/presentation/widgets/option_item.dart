import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';

class OptionItem extends StatelessWidget {
  const OptionItem._({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.subtitle,
    required this.overrideSubtitle,
    required this.onTap,
  });

  factory OptionItem.trailing({
    required IconData icon,
    required String title,
    required Widget trailing,
    String? subtitle,
    Widget? overrideSubtitle,
  }) {
    return OptionItem._(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      overrideSubtitle: overrideSubtitle,
      onTap: null,
    );
  }

  factory OptionItem.button({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? overrideSubtitle,
    Widget? trailing,
  }) {
    return OptionItem._(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      overrideSubtitle: overrideSubtitle,
      onTap: onTap,
    );
  }

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? overrideSubtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppStyle.detailsBorderRadius,
          splashFactory: InkRipple.splashFactory,
          child: _item(context),
        ),
      );
    }

    return _item(context);
  }

  Widget _item(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, size: 24, color: context.colorScheme.onSurface),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
              if (overrideSubtitle != null)
                overrideSubtitle!
              else if (subtitle != null)
                Text(
                  subtitle!,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null)
          SizedBox(
            width: 80,
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
      ],
    );
  }
}
