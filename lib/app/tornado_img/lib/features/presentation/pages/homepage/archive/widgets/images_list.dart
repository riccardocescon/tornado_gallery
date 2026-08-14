part of '../archive_page.dart';

/// The sliver list of archived images at the current level, with per-image
/// decrypt state while a background job runs. Selection state lives in the
/// page; this forwards toggle/activate taps.
class _ImagesList extends StatelessWidget {
  const _ImagesList({
    required this.selectedPaths,
    required this.onToggleSelection,
    required this.onActivateSelection,
  });

  final Set<String> selectedPaths;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<EncryptedImage> onActivateSelection;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          ui: (s) {
            final images = s.images;
            if (images.isEmpty) {
              return SliverToBoxAdapter(
                child:
                    s.folders.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: _NoImages(),
                        )
                        : const SizedBox.shrink(),
              );
            }

            // Per-image decrypt state while a background job for this folder runs.
            final job = s.activeJob;
            DearchivingStateType? tileStateFor(EncryptedImage image) {
              if (job == null) return null;
              final path = image.storagePath.file.path;
              final inJob = job.allImages.any(
                (e) => e.storagePath.file.path == path,
              );
              return inJob ? job.getState(path) : null;
            }

            return SliverList.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Column(
                  children: [
                    _ArchivedTile(
                      image: image,
                      dearchivingStateType: tileStateFor(image),
                      isSelectionMode: s.isSelectionMode,
                      isSelected: selectedPaths.contains(
                        image.storagePath.path,
                      ),
                      onToggleSelection:
                          () => onToggleSelection(image.storagePath.path),
                      onActivateSelection: () => onActivateSelection(image),
                    ),
                    if (index != images.length - 1)
                      Divider(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                  ],
                );
              },
            );
          },
          orElse: () => const SliverFillRemaining(child: _NoImages()),
        );
      },
    );
  }
}

/// Empty-state shown when the current folder has no archived images.
class _NoImages extends StatelessWidget {
  const _NoImages();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No archived images found",
          style: context.textTheme.headlineSmall!.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        Text(
          "Your archived images will appear here",
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
