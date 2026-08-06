part of '../settings_page.dart';

/// The "What's Tornado Gallery?" card: pitch, feature cards, and the current
/// storage-limit copy (which changes for Pro users).
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.cardBorderRadius,
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Tornado Gallery?",
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "Tornado Gallery aims to provide a new level of privacy for your photos by encyrpting them visually, preventing social embarrassment and adding an additional layer of security for picture scans from storage drivers",
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          _InfoCards(),
          Text(
            "Storage usage",
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, _) {
              final isPro = context.read<PurchaseBloc>().isPro;
              return Text(
                isPro
                    ? "Unlimited encrypted files and archives — thanks for going Pro."
                    : "Currently the storage limit is set to ${Constants.maxEncryptedImages} encrypted files and ${Constants.maxArchives} archives.\nGo Pro to remove both limits.",
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
