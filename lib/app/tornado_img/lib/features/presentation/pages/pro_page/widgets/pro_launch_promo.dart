part of '../pro_page.dart';

/// Launch-discount banner: pushes the user to grab Pro at the introductory
/// price before it goes up.
class _LaunchPromo extends StatelessWidget {
  const _LaunchPromo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: proGradient(context),
        borderRadius: AppStyle.proCardBorderRadius,
        boxShadow: proGlow(),
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.appColors.onPro.withValues(alpha: 0.16),
              borderRadius: AppStyle.detailsBorderRadius,
            ),
            child: Icon(
              Icons.local_offer_rounded,
              size: 21,
              color: context.appColors.onPro,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Launch discount",
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.appColors.onPro,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Grab the launch offer and get Pro forever at a discounted "
                  "price.\nOnly for a limited time only.",
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.appColors.onPro.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
