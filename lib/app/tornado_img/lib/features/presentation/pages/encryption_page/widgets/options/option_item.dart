part of '../../encryption_page.dart';

class _OptionItem extends StatelessWidget {
  const _OptionItem({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.overrideSubtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final Widget? overrideSubtitle;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          width: 80,
          child: Align(alignment: Alignment.centerRight, child: trailing),
        ),
      ],
    );
  }
}
