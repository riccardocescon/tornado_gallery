import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/utils/routes.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/theme/theme.dart';

/// Shared Pro surfaces: the purple gradient, the glow, the tinted icon chip and
/// the two upsell entry points (settings + archive card). Everything visual
/// about Pro lives here or in the theme — no widget hardcodes a colour.

/// The Pro gradient, used on every premium CTA and hero tile.
LinearGradient proGradient(BuildContext context) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    context.appColors.proGradientStart,
    context.appColors.proGradientEnd,
  ],
);

/// The purple glow under the Pro CTAs. The one place the app uses a coloured
/// shadow — DESIGN.md's "depth from borders, not shadows" is deliberately broken
/// here, because the glow is what marks a surface as premium.
List<BoxShadow> proGlow() => [
  BoxShadow(
    color: AppColors.proGlow.withValues(alpha: 1),
    blurRadius: 14,
    // Deflated so the glow hugs the widget, then pushed down far enough that the
    // blur clears the top edge — so it reads only along the bottom curve, never
    // as a halo above and below. offset.dy >= blurRadius + spreadRadius.
    spreadRadius: -3,
    offset: const Offset(0, 8),
  ),
];

/// The 38×38 rounded icon tile used on every Pro row.
class ProIconChip extends StatelessWidget {
  const ProIconChip({
    super.key,
    required this.icon,
    this.size = 38,
    this.filled = false,
  });

  final IconData icon;
  final double size;

  /// Gradient-filled (an entry point) rather than subtly tinted (a benefit).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? null : context.appColors.proSubtle,
        gradient: filled ? proGradient(context) : null,
        borderRadius: AppStyle.proChipBorderRadius,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled ? context.appColors.onPro : context.appColors.pro,
      ),
    );
  }
}

/// The gradient "Upgrade to Pro" card (Settings).
class ProUpgradeCard extends StatelessWidget {
  const ProUpgradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(Routes.pro),
      borderRadius: AppStyle.proCardBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: proGradient(context),
          borderRadius: AppStyle.proCardBorderRadius,
          boxShadow: proGlow(),
        ),
        child: Row(
          spacing: 14,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.appColors.onPro.withValues(alpha: 0.16),
                borderRadius: AppStyle.detailsBorderRadius,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 21,
                color: context.appColors.onPro,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upgrade to Pro",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.appColors.onPro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Unlimited images and archives",
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.appColors.onPro.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.appColors.onPro.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Pro active" card (Settings). Tappable for subscribers only, where it
/// opens the store's manage-subscription page.
class ProStatusCard extends StatelessWidget {
  const ProStatusCard({super.key, this.onManage});

  /// Null for lifetime owners — there is nothing to manage.
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onManage,
      borderRadius: AppStyle.proCardBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: AppStyle.proCardBorderRadius,
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: Row(
          spacing: 14,
          children: [
            const ProIconChip(icon: Icons.workspace_premium_rounded, size: 44),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pro active",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    onManage == null
                        ? "Thanks for the support — no limits"
                        : "Thanks for the support — tap to manage",
                    style: context.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            if (onManage != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// The "Unlock Pro" row appended to the archive-state card on the home page.
class ProUnlockRow extends StatelessWidget {
  const ProUnlockRow({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(Routes.pro),
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 2),
        child: Row(
          spacing: 13,
          children: [
            const ProIconChip(
              icon: Icons.workspace_premium_rounded,
              filled: true,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Unlock Pro",
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Unlimited images and archives",
                    style: context.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// The inline "you've hit the free limit" upsell shown above a blocked action
/// (the Encrypt button, the create-archive sheet).
class ProLimitBanner extends StatelessWidget {
  const ProLimitBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(Routes.pro),
      borderRadius: AppStyle.proButtonBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.appColors.proSubtle,
          borderRadius: AppStyle.proButtonBorderRadius,
          border: Border.all(
            color: context.appColors.pro.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: context.appColors.pro,
            ),
            Expanded(child: Text(message, style: context.textTheme.bodySmall)),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.appColors.pro,
            ),
          ],
        ),
      ),
    );
  }
}
