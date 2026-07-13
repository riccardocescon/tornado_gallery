import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/pages/pro_page/widgets/pro_plan_card.dart';
import 'package:tornado_img_app/features/presentation/pages/pro_page/widgets/pro_welcome_overlay.dart';
import 'package:tornado_img_app/features/presentation/widgets/pro_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// The paywall. Prices are always the store's own formatted strings — the app
/// never renders a price it made up.
class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  /// Lifetime is preselected: it is the recommended plan.
  ProPlan _selected = ProPlan.lifetime;

  List<ProProduct> _products = const [];
  bool _busy = false;
  bool _welcoming = false;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseBloc>().add(const PurchaseEvent.loadProducts());
  }

  ProProduct? get _selectedProduct =>
      _products.firstWhereOrNull((p) => p.plan == _selected);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listener: _onState,
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
                  children: [
                    _header(context),
                    const SizedBox(height: 20),
                    _hero(context),
                    const SizedBox(height: 22),
                    _benefits(context),
                    const SizedBox(height: 22),
                    ..._plans(context),
                    const SizedBox(height: 4),
                    _reassurance(context),
                    const SizedBox(height: 18),
                    _footerLinks(context),
                  ],
                ),
              ),
              _actionBar(context),
              if (_welcoming) ProWelcomeOverlay(plan: _selected),
            ],
          ),
        );
      },
    );
  }

  // ── State ───────────────────────────────────────────────────────────────────

  void _onState(BuildContext context, PurchaseState state) {
    state.maybeWhen(
      products:
          (products) => setState(() {
            _products = products;
            _busy = false;
            // Never offer a plan the store didn't return.
            if (_selectedProduct == null && products.isNotEmpty) {
              _selected = products.last.plan;
            }
          }),
      loadingProducts: () => setState(() => _busy = true),
      purchasing: () => setState(() => _busy = true),
      restoring: () => setState(() => _busy = true),
      restored: (restoredPro) {
        setState(() => _busy = false);
        if (!restoredPro) {
          context.showSnackbar("No previous purchase found to restore.");
        }
      },
      entitlement: (entitlement) {
        if (!entitlement.isPro || _welcoming) return;
        // Bought or restored: celebrate, then get out of the way.
        setState(() {
          _busy = false;
          if (entitlement.plan != null) _selected = entitlement.plan!;
          _welcoming = true;
        });

        final router = GoRouter.of(context);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (!mounted) return;
          if (router.canPop()) router.pop();
        });
      },
      failure: (message) {
        setState(() => _busy = false);
        context.showErrorSnackbar(message);
      },
      orElse: () {},
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: AppStyle.detailsBorderRadius,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: AppStyle.detailsBorderRadius,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tornado Gallery Pro",
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "No limits on your privacy",
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            gradient: proGradient(context),
            borderRadius: AppStyle.proCardBorderRadius,
            boxShadow: proGlow(),
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            size: 34,
            color: context.appColors.onPro,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            "Go Pro and remove every limit in Tornado Gallery.",
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _benefits(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.proCardBorderRadius,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _benefit(context, Icons.lock_rounded, "Unlimited image encryption"),
          _divider(context),
          _benefit(
            context,
            Icons.inventory_2_rounded,
            "Unlimited archives to organise your files",
          ),
          _divider(context),
          _benefit(
            context,
            Icons.verified_user_rounded,
            "Every new feature included",
          ),
        ],
      ),
    );
  }

  Widget _benefit(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        spacing: 13,
        children: [
          ProIconChip(icon: icon),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: context.colorScheme.outlineVariant.withValues(alpha: 0.7),
  );

  List<Widget> _plans(BuildContext context) {
    if (_products.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child:
                _busy
                    ? const CircularProgressIndicator()
                    : Text(
                      "Pro is not available right now. Please try again later.",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall,
                    ),
          ),
        ),
      ];
    }

    return [
      for (final product in _products) ...[
        ProPlanCard(
          product: product,
          selected: product.plan == _selected,
          onTap: () => setState(() => _selected = product.plan),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _reassurance(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.softBackground,
        borderRadius: AppStyle.proButtonBorderRadius,
        border: Border.all(color: context.colorScheme.outlineVariant),
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

  Widget _footerLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 14,
      children: [
        _link(context, "Terms of Service", () => _open(Constants.termsUrl)),
        _dot(context),
        _link(context, "Privacy Policy", () => _open(Constants.privacyUrl)),
        _dot(context),
        _link(
          context,
          "Restore purchases",
          () => context.read<PurchaseBloc>().add(const PurchaseEvent.restore()),
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

  // ── Action bar ──────────────────────────────────────────────────────────────

  Widget _actionBar(BuildContext context) {
    final product = _selectedProduct;

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
        child: _cta(context, product),
      ),
    );
  }

  Widget _cta(BuildContext context, ProProduct? product) {
    final enabled = product != null && !_busy;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        onTap:
            enabled
                ? () => context.read<PurchaseBloc>().add(
                  PurchaseEvent.buy(product: product),
                )
                : null,
        borderRadius: AppStyle.proButtonBorderRadius,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: proGradient(context),
            borderRadius: AppStyle.proButtonBorderRadius,
            boxShadow: enabled ? proGlow() : null,
          ),
          child:
              _busy
                  ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: context.appColors.onPro,
                    ),
                  )
                  : Text(
                    _ctaLabel(product),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.appColors.onPro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
        ),
      ),
    );
  }

  String _ctaLabel(ProProduct? product) {
    if (product == null) return "Unavailable";
    return switch (product.plan) {
      ProPlan.monthly => "Continue with Monthly · ${product.price}/month",
      ProPlan.lifetime => "Continue with Lifetime · ${product.price}",
    };
  }

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
