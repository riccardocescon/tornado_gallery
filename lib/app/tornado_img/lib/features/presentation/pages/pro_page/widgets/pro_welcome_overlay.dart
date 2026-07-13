import 'package:flutter/material.dart';
import 'package:tornado_img_app/core/domain/entities/pro_product.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/presentation/widgets/pro_widgets.dart';

/// The "Welcome to Pro" celebration shown over the paywall right after a
/// successful purchase or restore, before the page pops itself.
class ProWelcomeOverlay extends StatefulWidget {
  const ProWelcomeOverlay({super.key, required this.plan});

  final ProPlan plan;

  @override
  State<ProWelcomeOverlay> createState() => _ProWelcomeOverlayState();
}

class _ProWelcomeOverlayState extends State<ProWelcomeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.78),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 18,
          children: [
            ScaleTransition(
              scale: _pop,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: proGradient(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: proGlow(),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: context.appColors.onPro,
                ),
              ),
            ),
            Column(
              spacing: 3,
              children: [
                Text(
                  "Welcome to Pro",
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  switch (widget.plan) {
                    ProPlan.monthly => "Monthly subscription active",
                    ProPlan.lifetime => "Pro forever — thank you!",
                  },
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
