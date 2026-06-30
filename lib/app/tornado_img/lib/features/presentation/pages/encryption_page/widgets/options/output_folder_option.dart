part of '../../encryption_page.dart';

class _OutputFolderOption extends StatelessWidget {
  const _OutputFolderOption();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            settingsUi: (state) => true,
            orElse: () => false,
          ),
      builder: (context, state) {
        final settings = state.maybeMap(
          settingsUi: (state) => state.settings,
          orElse: () => null,
        );
        final outputFolder = settings?.outputFolder ?? "";
        final isLoading = outputFolder.isEmpty;
        final isPrivate = settings != null && !settings.galleryVisible;

        return OptionItem.trailing(
          icon: Icons.folder_outlined,
          title: "Output Folder",
          overrideSubtitle:
              isLoading ? LoadingContainer(width: 300, height: 16) : null,
          subtitle: outputFolder,
          trailing:
              settings != null
                  ? TextButton(
                    onPressed:
                        () => _pick(
                          context,
                          isPrivate: isPrivate,
                          currentRelative: settings.publicRelativeAlbum,
                        ),
                    child: Text(
                      "Change",
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colorScheme.tertiary,
                      ),
                    ),
                  )
                  : Container(),
        );
      },
    );
  }

  Future<void> _pick(
    BuildContext context, {
    required bool isPrivate,
    required String currentRelative,
  }) async {
    final selected = await showModalBottomSheet<_OutputFolderSelection>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: AppStyle.cardBorderRadius.topLeft,
        ),
      ),
      builder: (_) => _OutputFolderBottomSheet(isPrivate: isPrivate),
    );
    if (selected == null || !context.mounted) return;

    if (selected.isPrivate) {
      context.read<EncryptionPageBloc>().add(
        EncryptionPageEvent.setOutputFolder(
          relative: selected.value,
          label: selected.label,
        ),
      );
    } else {
      context.read<EncryptionPageBloc>().add(
        EncryptionPageEvent.setPublicAlbum(
          relative: selected.value,
          label: selected.label,
        ),
      );
    }
  }
}

/// A chosen encryption destination. [value] is the folder path relative to the
/// store root ('' = root) for both stores — private (encrypted) and public
/// (gallery). [label] is the UI subtitle.
class _OutputFolderSelection {
  final bool isPrivate;
  final String value;
  final String label;

  const _OutputFolderSelection({
    required this.isPrivate,
    required this.value,
    required this.label,
  });
}

/// Lets the user pick (or create) a destination folder in the store dictated by
/// the Gallery-visibility toggle. Pops an [_OutputFolderSelection].
class _OutputFolderBottomSheet extends StatefulWidget {
  const _OutputFolderBottomSheet({required this.isPrivate});

  final bool isPrivate;

  @override
  State<_OutputFolderBottomSheet> createState() =>
      _OutputFolderBottomSheetState();
}

class _OutputFolderBottomSheetState extends State<_OutputFolderBottomSheet> {
  List<String> _relativeFolders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final relatives =
        widget.isPrivate ? await _loadPrivate() : await _loadPublic();
    if (!mounted) return;
    setState(() {
      _relativeFolders = relatives.toList()..sort();
      _loading = false;
    });
  }

  Future<Set<String>> _loadPrivate() async {
    final root = await GalleryPathProvider.getPrivateFolderPath();
    final relatives = <String>{};
    try {
      final dir = Directory(root);
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! Directory) continue;
        final rel = _relativeUnder(root, entity.path);
        if (rel.isNotEmpty) relatives.add(rel);
      }
    } catch (_) {}
    return relatives;
  }

  Future<Set<String>> _loadPublic() async {
    final relatives = <String>{};
    if (Platform.isIOS) {
      // Gallery folders are modelled as albums named `<root>/<relative>`.
      final rootAlbum = GalleryPathProvider.getPublicAlbumName('');
      final albums = await GalleryPathProvider.listPublicAlbumsUnder(rootAlbum);
      for (final album in albums) {
        if (album.name == rootAlbum) continue;
        final rel = album.name.substring(rootAlbum.length + 1);
        if (rel.trim().isNotEmpty) relatives.add(rel);
      }
    } else {
      // Android: the public album maps to a real directory tree.
      final root = await GalleryPathProvider.getPublicFolderPath();
      if (root != null) {
        try {
          final dir = Directory(root);
          if (await dir.exists()) {
            await for (final entity in dir.list(
              recursive: true,
              followLinks: false,
            )) {
              if (entity is! Directory) continue;
              final rel = _relativeUnder(root, entity.path);
              if (rel.isNotEmpty) relatives.add(rel);
            }
          }
        } catch (_) {}
      }
    }
    return relatives;
  }

  String _relativeUnder(String root, String path) {
    return path
        .replaceAll('\\', '/')
        .substring(root.replaceAll('\\', '/').length)
        .split('/')
        .where((p) => p.trim().isNotEmpty)
        .join('/');
  }

  _OutputFolderSelection _selectionFor(String relative) {
    if (widget.isPrivate) {
      // Relative path only; the absolute path is resolved at save time so it
      // stays in sync with the archive page (also relative-based).
      return _OutputFolderSelection(
        isPrivate: true,
        value: relative,
        label: relative.isEmpty ? 'Root (encrypted)' : relative,
      );
    }
    final label =
        relative.isEmpty ? 'Device Gallery' : 'Device Gallery / $relative';
    return _OutputFolderSelection(
      isPrivate: false,
      value: relative,
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rootTitle = widget.isPrivate ? "Root (encrypted)" : "Root (gallery)";
    return SafeArea(
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Output Folder", style: context.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home_rounded),
                        title: Text(rootTitle),
                        onTap: () => Navigator.pop(context, _selectionFor('')),
                      ),
                      ..._relativeFolders.map(
                        (rel) => ListTile(
                          leading: const Icon(Icons.folder_rounded),
                          title: Text(rel),
                          onTap:
                              () => Navigator.pop(context, _selectionFor(rel)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
