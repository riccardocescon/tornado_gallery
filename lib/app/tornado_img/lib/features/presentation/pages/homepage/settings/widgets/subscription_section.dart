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
            // A monthly subscriber gets a single gradient card: it tips them
            // toward the lifetime unlock. Tapping it opens the paywall, which
            // auto-filters to the Lifetime plan for a monthly subscriber.
            else if (purchases.plan == ProPlan.monthly)
              const ProUpgradeCard(
                title: "Upgrade to Lifetime",
                subtitle: "One payment, Pro forever",
              )
            // Lifetime: nothing to manage.
            else
              const ProStatusCard(),
          ],
        );
      },
    );
  }
}
