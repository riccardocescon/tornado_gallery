part of '../pro_page.dart';

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppStyle.proCardBorderRadius,
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
}
