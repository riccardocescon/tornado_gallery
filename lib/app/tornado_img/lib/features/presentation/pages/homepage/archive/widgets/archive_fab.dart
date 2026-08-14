part of '../archive_page.dart';

/// The floating action button: progress while a background job runs, otherwise
/// a decrypt/encrypt toggle for the current folder (hidden when empty).
class _ArchiveFab extends StatelessWidget {
  const _ArchiveFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (value) => true, orElse: () => false),
      builder: (context, state) {
        final archiveBloc = context.read<ArchivePageBloc>();
        final activeJob = state.maybeMap(
          ui: (s) => s.activeJob,
          orElse: () => null,
        );
        final hasDecryptedAll = archiveBloc.hasAllDecrypted;

        // A background decrypt is running for this folder → show progress.
        if (activeJob != null) {
          return FloatingActionButton(
            onPressed:
                () => context.read<ArchivePageBloc>().add(
                  const ArchivePageEvent.encryptAll(),
                ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value:
                    activeJob.totalImages == 0
                        ? null
                        : activeJob.progress / activeJob.totalImages,
                color: context.colorScheme.onPrimary,
              ),
            ),
          );
        }

        // No images at the current navigation level → nothing to decrypt/encrypt.
        if (archiveBloc.currentFolderImages.isEmpty) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () {
            if (hasDecryptedAll) {
              context.read<ArchivePageBloc>().add(
                const ArchivePageEvent.encryptAll(),
              );
              return;
            }
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (_) => UnlockAllBottomSheet(
                    onUnlockAll: (passphrase) {
                      context.read<ArchivePageBloc>().add(
                        ArchivePageEvent.decryptAll(passphrase: passphrase),
                      );
                    },
                  ),
            );
          },
          child: Icon(
            hasDecryptedAll ? Icons.lock_rounded : Icons.lock_open_rounded,
          ),
        );
      },
    );
  }
}
