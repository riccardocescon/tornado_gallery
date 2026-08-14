part of '../pro_page.dart';

class _Hero extends StatelessWidget {
  const _Hero({required this.isUpgrade});

  final bool isUpgrade;

  @override
  Widget build(BuildContext context) {
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
            isUpgrade
                ? "Upgrade to Lifetime and pay once — Pro forever."
                : "Go Pro and remove every limit in Tornado Gallery.",
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
}
