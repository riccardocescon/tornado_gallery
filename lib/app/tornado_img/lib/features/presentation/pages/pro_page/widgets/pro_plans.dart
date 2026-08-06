part of '../pro_page.dart';

class _Plans extends StatelessWidget {
  const _Plans({
    required this.products,
    required this.selected,
    required this.busy,
    required this.onSelect,
  });

  final List<ProProduct> products;
  final ProPlan selected;
  final bool busy;
  final ValueChanged<ProPlan> onSelect;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child:
              busy
                  ? const CircularProgressIndicator()
                  : Text(
                    "Pro is not available right now. Please try again later.",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall,
                  ),
        ),
      );
    }

    return Column(
      children: [
        for (final product in products) ...[
          ProPlanCard(
            product: product,
            selected: product.plan == selected,
            onTap: () => onSelect(product.plan),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
