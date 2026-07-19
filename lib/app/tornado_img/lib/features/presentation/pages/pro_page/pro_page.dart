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

part 'widgets/pro_header.dart';
part 'widgets/pro_hero.dart';
part 'widgets/pro_benefits.dart';
part 'widgets/pro_launch_promo.dart';
part 'widgets/pro_plans.dart';
part 'widgets/pro_footer.dart';
part 'widgets/pro_action_bar.dart';

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

  /// The plan the user already owned when they opened the paywall (null when
  /// free). A monthly subscriber is here to upgrade to lifetime.
  ProPlan? _entryPlan;
  bool get _isUpgrade => _entryPlan == ProPlan.monthly;

  @override
  void initState() {
    super.initState();
    _entryPlan = context.read<PurchaseBloc>().plan;
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
                    const _Header(),
                    const SizedBox(height: 20),
                    _Hero(isUpgrade: _isUpgrade),
                    const SizedBox(height: 22),
                    const _Benefits(),
                    const SizedBox(height: 22),
                    const _LaunchPromo(),
                    const SizedBox(height: 22),
                    _Plans(
                      products: _products,
                      selected: _selected,
                      busy: _busy,
                      onSelect: (plan) => setState(() => _selected = plan),
                    ),
                    const SizedBox(height: 4),
                    const _Reassurance(),
                    const SizedBox(height: 18),
                    _FooterLinks(isUpgrade: _isUpgrade),
                  ],
                ),
              ),
              _ActionBar(
                product: _selectedProduct,
                busy: _busy,
                isUpgrade: _isUpgrade,
                onBuy:
                    (product) => context.read<PurchaseBloc>().add(
                      PurchaseEvent.buy(product: product),
                    ),
              ),
              if (_welcoming) ProWelcomeOverlay(plan: _selected),
            ],
          ),
        );
      },
    );
  }


  void _onState(BuildContext context, PurchaseState state) {
    state.maybeWhen(
      products:
          (products) => setState(() {
            // A monthly subscriber already owns monthly — only lifetime is an
            // upgrade, so don't offer them the plan they already have.
            _products =
                _isUpgrade
                    ? products
                        .where((p) => p.plan == ProPlan.lifetime)
                        .toList()
                    : products;
            _busy = false;
            // Never offer a plan the store didn't return.
            if (_selectedProduct == null && _products.isNotEmpty) {
              _selected = _products.last.plan;
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
        // Celebrate only when the plan advances past what we entered with, so a
        // silent resume-restore (same plan) never pops a user mid-upgrade.
        if (!entitlement.isPro ||
            _welcoming ||
            entitlement.plan == _entryPlan) {
          return;
        }
        // Bought or upgraded: celebrate, then get out of the way.
        final isUpgrade = _isUpgrade;
        setState(() {
          _busy = false;
          if (entitlement.plan != null) _selected = entitlement.plan!;
          _welcoming = true;
        });

        final router = GoRouter.of(context);
        Future.delayed(const Duration(milliseconds: 1600), () {
          if (!mounted) return;
          // The lifetime unlock doesn't cancel the monthly subscription — nudge
          // the user to cancel it so they aren't billed twice.
          if (isUpgrade) {
            _promptCancelMonthly(router);
          } else if (router.canPop()) {
            router.pop();
          }
        });
      },
      failure: (message) {
        setState(() => _busy = false);
        context.showErrorSnackbar(message);
      },
      orElse: () {},
    );
  }

  /// After a monthly → lifetime upgrade the subscription is still live (no store
  /// auto-cancels it), so point the user at the store to cancel it.
  Future<void> _promptCancelMonthly(GoRouter router) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("You're Lifetime Pro now"),
            content: const Text(
              "Your monthly subscription is still active. Cancel it so you're "
              "not billed again — your Lifetime unlock never expires.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Later"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openManageSubscription();
                },
                child: const Text("Cancel subscription"),
              ),
            ],
          ),
    );
    if (mounted && router.canPop()) router.pop();
  }
}
