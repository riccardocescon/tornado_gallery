part of '../settings_page.dart';

/// "Upgrade to Pro" when free, "Pro active" when not. Rebuilt on entitlement
/// changes so a purchase made on the paywall is reflected the moment we're
/// back here.
class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, _) {
        final purchases = context.read<PurchaseBloc>();

        return Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SUBSCRIPTION",
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            if (!purchases.isPro)
              const ProUpgradeCard()
            else
              ProStatusCard(
                // Nothing to manage for a lifetime unlock.
                onManage:
                    purchases.plan == ProPlan.monthly
                        ? _openManageSubscription
                        : null,
              ),
          ],
        );
      },
    );
  }

  /// The plugin exposes no manage-subscription API, so we deep-link the store.
  Future<void> _openManageSubscription() {
    return launchUrl(
      Uri.parse(
        Platform.isIOS
            ? Constants.manageSubscriptionIos
            : Constants.manageSubscriptionAndroid,
      ),
      mode: LaunchMode.externalApplication,
    );
  }
}
