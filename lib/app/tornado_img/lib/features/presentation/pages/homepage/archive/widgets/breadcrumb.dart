part of '../archive_page.dart';

/// The `/ folder / subfolder` path line, hidden at the archive root.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        final breadcrumb = state.maybeMap(
          ui: (s) => s.breadcrumb,
          orElse: () => <String>[],
        );
        final atRoot = state.maybeMap(
          ui: (s) => s.currentIsPrivate == null && s.currentPath.isEmpty,
          orElse: () => true,
        );
        if (atRoot) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            breadcrumb.isEmpty ? "/" : "/ ${breadcrumb.join(" / ")}",
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
