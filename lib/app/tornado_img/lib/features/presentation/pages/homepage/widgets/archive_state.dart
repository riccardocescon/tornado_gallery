part of '../homepage.dart';

class _ArchiveState extends StatelessWidget {
  const _ArchiveState();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: AppStyle.cardBorderRadius,
          ),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Archive state",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: 1.5,
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              _item(context, Icons.folder_rounded, "123 encrypted files"),
              Container(
                height: 1.5,
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              _item(context, Icons.archive_rounded, "5 archives"),
              Container(
                height: 1.5,
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              Column(
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Icon(Icons.safety_check_rounded),
                      const SizedBox(width: 8),
                      Text(
                        "1.5 GB protected",
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Last encrypted: 2 days ago",
                    style: context.textTheme.bodyMedium,
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: context.appColors.softButton,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            AppStyle.cardBorderRadius -
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 18,
                              color: context.colorScheme.primary,
                            ),
                            Text(
                              "Open archive",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: context.colorScheme.primary.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, IconData icon, String text) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: context.colorScheme.primary),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: context.colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
