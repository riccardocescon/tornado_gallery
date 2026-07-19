part of '../archive_page.dart';

/// The pill showing "N archived file(s)" for the current folder level.
class _EncryptedFilesBadge extends StatelessWidget {
  const _EncryptedFilesBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          ui: (s) {
            final encryptedCount = s.images.length;
            if (encryptedCount == 0) return const SizedBox();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.appColors.softBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "$encryptedCount archived ${encryptedCount == 1 ? "file" : "files"}",
                style: context.textTheme.labelMedium!.copyWith(
                  color:
                      context.isDarkMode
                          ? context.colorScheme.onPrimary.withValues(alpha: 0.7)
                          : context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}
