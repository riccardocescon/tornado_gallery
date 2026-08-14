part of '../pro_page.dart';

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.product,
    required this.busy,
    required this.isUpgrade,
    required this.onBuy,
  });

  final ProProduct? product;
  final bool busy;
  final bool isUpgrade;
  final ValueChanged<ProProduct> onBuy;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          22 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              context.appColors.scaffoldBackground,
              context.appColors.scaffoldBackground.withValues(alpha: 0),
            ],
            stops: const [0.6, 1],
          ),
        ),
        child: _cta(context),
      ),
    );
  }

  Widget _cta(BuildContext context) {
    final enabled = product != null && !busy;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap: enabled ? () => onBuy(product!) : null,
        borderRadius: AppStyle.proButtonBorderRadius,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: proGradient(context),
            borderRadius: AppStyle.proButtonBorderRadius,
            boxShadow: enabled ? proGlow() : null,
          ),
          child:
              busy
                  ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: context.appColors.onPro,
                    ),
                  )
                  : Text(
                    _ctaLabel(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.appColors.onPro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
        ),
      ),
    );
  }

  String _ctaLabel() {
    final product = this.product;
    if (product == null) return "Unavailable";
    if (isUpgrade) return "Upgrade to Lifetime · ${product.price}";
    return switch (product.plan) {
      ProPlan.monthly => "Continue with Monthly · ${product.price}/month",
      ProPlan.lifetime => "Continue with Lifetime · ${product.price}",
    };
  }
}
