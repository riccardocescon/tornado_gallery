part of '../home_page.dart';

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
            border: Border.all(
              color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Archive state",
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              BlocBuilder<HomepageBloc, HomepageState>(
                buildWhen:
                    (previous, current) => current.maybeMap(
                      galleryStatus: (state) => true,
                      orElse: () => false,
                    ),
                builder: (context, state) {
                  return state.maybeMap(
                    galleryStatus: (value) {
                      final archivingState = value.archivingState;
                      if (archivingState == null) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        spacing: 8,
                        children: [
                          Container(
                            height: 1.5,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          _archivingItem(context, archivingState),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
              Container(
                height: 1.5,
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              BlocBuilder<HomepageBloc, HomepageState>(
                buildWhen:
                    (previous, current) => current.maybeMap(
                      galleryStatus: (state) => true,
                      orElse: () => false,
                    ),
                builder: (context, state) {
                  final amount = state.maybeMap(
                    galleryStatus: (value) => value.imagesLoaded,
                    orElse: () => null,
                  );

                  final folderAmount = state.maybeMap(
                    galleryStatus: (value) => value.folderLoaded,
                    orElse: () => null,
                  );

                  final bytesAmount = state.maybeMap(
                    galleryStatus: (value) => value.bytesLoaded,
                    orElse: () => null,
                  );

                  final lastEncrypted = state.maybeMap(
                    galleryStatus: (value) => value.lastLoaded,
                    orElse: () => null,
                  );

                  return Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _item(
                        context,
                        Icons.folder_rounded,
                        amount?.toString(),
                        "encrypted files",
                      ),
                      Container(
                        height: 1.5,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      _item(
                        context,
                        Icons.archive_rounded,
                        folderAmount?.toString(),
                        "archives",
                      ),
                      Container(
                        height: 1.5,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      _byteProtectedItem(context, bytesAmount, lastEncrypted),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String? value,
    String text,
  ) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: context.colorScheme.onSurface),

        Row(
          spacing: 4,
          children: [
            value == null
                ? LoadingContainer(width: 40)
                : Text(
                  value,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.onSurface,
                  ),
                ),
            Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
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

  Widget _byteProtectedItem(
    BuildContext context,
    int? amount,
    DateTime? lastEncrypted,
  ) {
    String? sizeLabel;
    String sizeUnit = "B";
    if (amount != null) {
      if (amount < 1024) {
        sizeLabel = amount.toString();
        sizeUnit = "B";
      } else if (amount < 1024 * 1024) {
        sizeLabel = (amount / 1024).toStringAsFixed(2);
        sizeUnit = "KB";
      } else if (amount < 1024 * 1024 * 1024) {
        sizeLabel = (amount / (1024 * 1024)).toStringAsFixed(2);
        sizeUnit = "MB";
      } else {
        sizeLabel = (amount / (1024 * 1024 * 1024)).toStringAsFixed(2);
        sizeUnit = "GB";
      }
    }

    final diffDays =
        lastEncrypted != null
            ? DateTime.now().difference(lastEncrypted).inDays
            : null;

    final lastDaySentence =
        diffDays == 0
            ? "Today"
            : diffDays == 1
            ? "Yesterday"
            : "$diffDays days ago";

    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.safety_check_rounded),
            Row(
              spacing: 4,
              children: [
                sizeLabel == null
                    ? LoadingContainer(width: 40)
                    : Text(
                      sizeLabel,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                Text(
                  "$sizeUnit protected",
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (diffDays != null)
          Text(
            "Last encrypted: $lastDaySentence",
            style: context.textTheme.bodyMedium,
          ),
        _openArchiveButton(context),
      ],
    );
  }

  Widget _openArchiveButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        context.read<HomepageBloc>().add(
          HomepageEvent.setScreen(page: Pages.archive),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: context.appColors.softButton,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: context.colorScheme.onSurface,
              ),
              Text(
                "Open archive",
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: context.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _archivingItem(BuildContext context, ArchivingState archivingState) {
    final successImages = archivingState.archivedImages.length;
    final failedImages = archivingState.failedImages.length;
    final processingImages =
        archivingState.totalImages - successImages - failedImages;

    final success = '$successImages Archived';
    final failed = '$failedImages Failed';
    final processing = '$processingImages Processing';

    Widget chip(
      String text,
      Color foreground,
      Color background, {
      Widget? tail,
    }) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppStyle.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
          if (tail != null) ...[const SizedBox(width: 6), tail],
        ],
      ),
    );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (successImages > 0)
          chip(
            success,
            context.appColors.success,
            context.appColors.successContainer,
            tail: Icon(
              Icons.check_rounded,
              size: 16,
              color: context.appColors.success,
            ),
          ),

        if (failedImages > 0)
          chip(
            failed,
            context.colorScheme.error,
            context.colorScheme.errorContainer,
            tail: Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: context.colorScheme.error,
            ),
          ),

        if (processingImages > 0)
          chip(
            processing,
            context.colorScheme.primary,
            context.colorScheme.primaryContainer.withValues(alpha: 0.1),
            tail: const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.2),
            ),
          ),
      ],
    );
  }
}
