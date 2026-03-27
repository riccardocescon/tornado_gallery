part of '../encryption_page.dart';

class _ArchivingStateCard extends StatelessWidget {
  const _ArchivingStateCard({required this.archivingState});

  final ArchivingState archivingState;

  @override
  Widget build(BuildContext context) {
    final archivedImages = archivingState.archivedImages.length;
    final failedImages = archivingState.failedImages.length;
    final remainingImages =
        archivingState.totalImages - archivedImages - failedImages;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        boxShadow:
            context.isDarkMode
                ? null
                : [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Archiving State", style: context.textTheme.titleMedium),
          Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(
                context,
                "Remaining",
                remainingImages.toString(),
                context.colorScheme.primary,
              ),

              if (archivedImages > 0) ...[
                Container(
                  height: 1,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _item(
                  context,
                  "Archived",
                  archivedImages.toString(),
                  context.appColors.success.withValues(alpha: 0.8),
                ),
              ],

              if (failedImages > 0) ...[
                Container(
                  height: 1,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                _item(
                  context,
                  "Failed",
                  failedImages.toString(),
                  context.colorScheme.error.withValues(alpha: 0.8),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, String value, Color? color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textTheme.bodyMedium),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
