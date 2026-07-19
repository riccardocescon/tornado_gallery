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
                    const _Header(),
                    const SizedBox(height: 20),
                    const _Hero(),
                    const SizedBox(height: 22),
                    const _Benefits(),
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
                    const _FooterLinks(),
                  ],
                ),
              ),
              _ActionBar(
                product: _selectedProduct,
                busy: _busy,
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
}
