part of '../pro_page.dart';

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.softBackground,
        borderRadius: AppStyle.proButtonBorderRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Text(
              "Not sure? Try Pro with the monthly plan for a month or two — you "
              "can switch to Lifetime whenever you want.",
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks({required this.isUpgrade});

  /// A monthly subscriber has nothing to restore — they're here to upgrade —
  /// so the third link manages their subscription instead.
  final bool isUpgrade;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 14,
      children: [
        _link(context, "Terms of Service", () => _open(Constants.termsUrl)),
        _dot(context),
        _link(context, "Privacy Policy", () => _open(Constants.privacyUrl)),
        _dot(context),
        if (isUpgrade)
          _link(context, "Manage subscription", openManageSubscription)
        else
          _link(
            context,
            "Restore purchases",
            () =>
                context.read<PurchaseBloc>().add(const PurchaseEvent.restore()),
          ),
      ],
    );
  }

  Widget _link(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(fontSize: 12),
      ),
    );
  }

  Widget _dot(BuildContext context) => Text(
    "·",
    style: context.textTheme.labelMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
    ),
  );

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
