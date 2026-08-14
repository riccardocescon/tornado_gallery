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
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Divider(
                  height: 2,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _item(
                        context,
                        Icons.folder_rounded,
                        amount?.toString(),
                        "encrypted files",
                        () => _openArchive(context),
                      ),
                      Divider(
                        height: 2,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      _item(
                        context,
                        Icons.archive_rounded,
                        folderAmount?.toString(),
                        "archives",
                        () => _openArchive(context),
                      ),
                      Divider(
                        height: 2,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _byteProtectedItem(
                          context,
                          bytesAmount,
                          lastEncrypted,
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _usageBar(context),
                      ),
                      _proRow(context),
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
    VoidCallback? onTap,
  ) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyle.cardBorderRadius,
        splashFactory: InkRipple.splashFactory,
        splashColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
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
          ),
        ),
      ),
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
      onPressed: () => _openArchive(context),
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
    final skippedImages = archivingState.skippedImages.length;
    final processingImages =
        archivingState.totalImages -
        successImages -
        failedImages -
        skippedImages;

    final success = '$successImages Archived';
    final failed = '$failedImages Failed';
    final processing = '$processingImages Processing';
    final skipped = '$skippedImages Skipped';

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

        if (skippedImages > 0)
          chip(
            skipped,
            context.colorScheme.error,
            context.colorScheme.errorContainer,
            tail: Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: context.colorScheme.error,
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

  /// What the usage bar becomes for a Pro user: there is nothing to meter.
  Widget _unlimitedUsage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Storage usage",
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        Text(
          "Unlimited",
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.appColors.pro,
          ),
        ),
      ],
    );
  }

  /// The "Unlock Pro" entry point, appended to the card for free users only.
  Widget _proRow(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, _) {
        if (context.read<PurchaseBloc>().isPro) return const SizedBox.shrink();

        return Column(
          children: [
            Divider(
              height: 2,
              color: context.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const ProUnlockRow(),
          ],
        );
      },
    );
  }

  Widget _usageBar(BuildContext context) {
    return BlocBuilder<HomepageBloc, HomepageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(galleryStatus: (_) => true, orElse: () => false),
      builder: (context, state) {
        // Pro has no cap, so there is no bar to fill and no ratio to show.
        if (getIt<PurchaseBloc>().isPro) return _unlimitedUsage(context);

        final totalImages = state.maybeMap(
          galleryStatus: (value) => value.imagesLoaded,
          orElse: () => getIt<AppBloc>().encryptedImages.length,
        );

        final percentage =
            totalImages > 0
                ? (totalImages / Constants.maxEncryptedImages).clamp(0, 1)
                : 0.0;

        final barColor =
            percentage < 0.7
                ? context.colorScheme.primary
                : percentage < 0.9
                ? Colors.orange
                : context.colorScheme.error;

        return Material(
          child: InkWell(
            onTap: () {
              context.read<HomepageBloc>().add(
                HomepageEvent.setScreen(page: Pages.settings),
              );
            },
            borderRadius: AppStyle.cardBorderRadius,
            splashFactory: InkRipple.splashFactory,
            splashColor: context.colorScheme.onSurface.withValues(alpha: 0.1),
            child: Column(
              spacing: 6,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Storage usage",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "${(percentage * 100).toStringAsFixed(1)}%",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: AppStyle.cardBorderRadius,
                  child: Stack(
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(
                            alpha: context.isDarkMode ? 0.3 : 0.1,
                          ),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            width: percentage * constraints.maxWidth,
                            height: 12,
                            decoration: BoxDecoration(color: barColor),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Encrypted images: $totalImages/${Constants.maxEncryptedImages}",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
