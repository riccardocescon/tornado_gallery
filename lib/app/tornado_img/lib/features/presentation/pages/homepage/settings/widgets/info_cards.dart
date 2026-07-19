part of '../settings_page.dart';

class _InfoCards extends StatelessWidget {
  const _InfoCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        _card(
          context,
          Icons.shield_rounded,
          'Local Only',
          'Your photos never leave your device, all encryption and decryption happens locally on your device',
          iconColor: Colors.green,
        ),
        _card(
          context,
          Icons.key_rounded,
          'Strong Encryption',
          'Intrinsic your image with a passphrase of any length',
          iconColor: Colors.blue,
        ),
        _card(
          context,
          Icons.code_rounded,
          'Open Source',
          'The source code of Tornado Gallery is available on GitHub, allowing anyone to inspect, modify, and contribute to the project.',
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    {
    Color? iconColor,
  }
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainedItem.icon(
            icon: icon,
            iconColor: iconColor?.withValues(alpha: 0.8),
            backgroundColor: iconColor?.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
