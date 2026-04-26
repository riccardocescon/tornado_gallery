part of '../home_page.dart';

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonIcon,
    required this.buttonText,
    required this.darker,
    required this.onPressed,
  });

  final bool darker;
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData buttonIcon;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        darker ? context.colorScheme.onPrimary : context.colorScheme.onSurface;

    final foregroundButtonColor =
        darker
            ? context.colorScheme.primaryContainer
            : context.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            darker
                ? context.colorScheme.primaryContainer
                : context.colorScheme.surface,
        borderRadius: AppStyle.cardBorderRadius,
        border:
            darker
                ? null
                : Border.all(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainedItem.icon(
            icon: icon,
            backgroundColor:
                darker
                    ? context.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.1,
                    )
                    : context.appColors.softBackground,
            iconColor: foregroundColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                title,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor:
                    darker
                        ? context.colorScheme.onPrimary
                        : context.appColors.softButton,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      AppStyle.cardBorderRadius - BorderRadius.circular(8),
                ),
              ),
              child: Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(buttonIcon, size: 14, color: foregroundButtonColor),
                  Text(
                    buttonText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: foregroundButtonColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
