import 'package:flutter/material.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/pro_widgets.dart';

/// One selectable plan on the paywall: a radio card carrying the store's own
/// price. Lifetime also carries the "Recommended" badge.
class ProPlanCard extends StatelessWidget {
  const ProPlanCard({
    super.key,
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final ProProduct product;
  final bool selected;
  final VoidCallback onTap;

  bool get _recommended => product.plan == ProPlan.lifetime;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? context.appColors.pro : context.colorScheme.outlineVariant;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppStyle.proPlanBorderRadius,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: AppStyle.proPlanBorderRadius,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              spacing: 14,
              children: [
                _radio(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(_subtitle, style: context.textTheme.labelMedium),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(_period, style: context.textTheme.labelMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_recommended)
          Positioned(
            top: -11,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: proGradient(context),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "Recommended",
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.appColors.onPro,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _radio(BuildContext context) {
    final color =
        selected ? context.appColors.pro : context.colorScheme.outlineVariant;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child:
          selected
              ? Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.appColors.pro,
                  ),
                ),
              )
              : null,
    );
  }

  String get _title => switch (product.plan) {
    ProPlan.monthly => "Monthly",
    ProPlan.lifetime => "Lifetime",
  };

  String get _subtitle => switch (product.plan) {
    ProPlan.monthly => "Ideal to try Pro with no commitment",
    ProPlan.lifetime => "One payment, Pro forever",
  };

  String get _period => switch (product.plan) {
    ProPlan.monthly => "/ month",
    ProPlan.lifetime => "one-off",
  };
}
