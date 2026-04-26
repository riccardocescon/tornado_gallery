part of '../home_page.dart';

class _InfoCards extends StatelessWidget {
  const _InfoCards();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: _card(
              context,
              Icons.shield_rounded,
              'Local Only',
              'Your photos never leave your device',
            ),
          ),
          Expanded(
            child: _card(
              context,
              Icons.key_rounded,
              'Strong Encryption',
              'Encrypt with passphrase',
            ),
          ),
          Expanded(
            child: _card(
              context,
              Icons.folder_outlined,
              'Organized',
              'Organization with albums and folders',
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.cardBorderRadius,
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainedItem.icon(icon: icon),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
