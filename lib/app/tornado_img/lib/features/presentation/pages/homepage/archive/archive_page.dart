import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/utils/picture_provider/pictures_provider.dart';
import 'package:tornado_img_app/core/utils/routes.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/import_image_asset.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/core/utils/file_name_validator.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';
import 'package:tornado_img_app/features/presentation/widgets/unlock_all_bottom_sheet.dart';

part 'widgets/archived_tile.dart';
part 'widgets/import_images_bottom_sheet.dart';
part 'widgets/archive_folder_tile.dart';
part 'widgets/move_target_sheet.dart';
part 'widgets/archive_header.dart';
part 'widgets/breadcrumb.dart';
part 'widgets/encrypted_files_badge.dart';
part 'widgets/folders_list.dart';
part 'widgets/images_list.dart';
part 'widgets/archive_fab.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final ScrollController _scrollController = ScrollController();
  static double _savedScrollOffset = 0;
  double? _dragStartX;

  final Set<String> _selectedPaths = {};

  /// The image list the archive is currently showing — read straight from the
  /// `ui` state so selection operations resolve against exactly what's rendered.
  List<EncryptedImage> get _currentImages =>
      context.read<ArchivePageBloc>().state.maybeMap(
        ui: (s) => s.images,
        orElse: () => <EncryptedImage>[],
      );

  void _activateSelection(EncryptedImage image) {
    setState(() {
      _selectedPaths.add(image.storagePath.path);
    });
    context.read<ArchivePageBloc>().add(
      const ArchivePageEvent.activateSelectionMode(),
    );
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedPaths.clear();
    });
    context.read<ArchivePageBloc>().add(
      const ArchivePageEvent.cancelSelectionMode(),
    );
  }

  void _deleteSelected() {
    final selectedImages =
        _currentImages
            .where((img) => _selectedPaths.contains(img.storagePath.path))
            .toList();
    context.read<ArchivePageBloc>().add(
      ArchivePageEvent.delete(images: selectedImages),
    );
    _cancelSelection();
  }

  // ── Folder actions ──────────────────────────────────────────────────────────

  Future<void> _promptNewFolder() async {
    final controller = TextEditingController();
    // At the root (mixed view) the store is ambiguous, so let the user pick;
    // inside a folder the store is fixed and no switch is shown.
    final atRoot = context.read<ArchivePageBloc>().state.maybeMap(
      ui: (s) => s.currentIsPrivate == null && s.currentPath.isEmpty,
      orElse: () => true,
    );
    bool isPrivate = true;

    final result = await showModalBottomSheet<(String, bool)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: AppStyle.cardBorderRadius.topLeft,
        ),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSheetState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    24 + MediaQuery.viewInsetsOf(ctx).bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ContainedItem.icon(
                            icon: Icons.create_new_folder_outlined,
                            backgroundColor: ctx.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            iconColor: ctx.colorScheme.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "New folder",
                                  style: ctx.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Organize your archived images",
                                  style: ctx.textTheme.bodySmall?.copyWith(
                                    color: ctx.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: "Folder name",
                          prefixIcon: const Icon(Icons.folder_outlined),
                          filled: true,
                          fillColor: ctx.appColors.softBackground.withValues(
                            alpha: 0.5,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppStyle.detailsBorderRadius,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppStyle.detailsBorderRadius,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppStyle.detailsBorderRadius,
                            borderSide: BorderSide(
                              color: ctx.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (v) => Navigator.pop(ctx, (v, isPrivate)),
                      ),
                      if (atRoot) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: true,
                                label: Text("Private"),
                                icon: Icon(Icons.lock_outline_rounded),
                              ),
                              ButtonSegment(
                                value: false,
                                label: Text("Public"),
                                icon: Icon(Icons.photo_library_outlined),
                              ),
                            ],
                            selected: {isPrivate},
                            onSelectionChanged:
                                (s) => setSheetState(() => isPrivate = s.first),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  () => Navigator.pop(ctx, (
                                    controller.text,
                                    isPrivate,
                                  )),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppStyle.detailsBorderRadius,
                                ),
                              ),
                              icon: const Icon(Icons.check_rounded, size: 20),
                              label: const Text("Create"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
    if (result != null && result.$1.trim().isNotEmpty && mounted) {
      context.read<ArchivePageBloc>().add(
        ArchivePageEvent.createFolder(
          name: result.$1.trim(),
          isPrivate: atRoot ? result.$2 : null,
        ),
      );
    }
  }

  Future<void> _promptRenameFolder(ArchiveFolderView folder) async {
    final controller = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Rename folder"),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: "Folder name"),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text("Rename"),
              ),
            ],
          ),
    );
    if (name != null && name.trim().isNotEmpty && mounted) {
      context.read<ArchivePageBloc>().add(
        ArchivePageEvent.renameFolder(
          relativePath: folder.relativePath,
          isPrivate: folder.isPrivate,
          newName: name.trim(),
        ),
      );
    }
  }

  Future<void> _confirmDeleteFolder(ArchiveFolderView folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete "${folder.name}"?'),
            content: Text(
              folder.imageCount == 0
                  ? "This folder is empty."
                  : "This will permanently delete ${folder.imageCount} image(s) inside it.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      context.read<ArchivePageBloc>().add(
        ArchivePageEvent.deleteFolder(
          relativePath: folder.relativePath,
          isPrivate: folder.isPrivate,
        ),
      );
    }
  }

  void _decryptFolder(ArchiveFolderView folder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => UnlockAllBottomSheet(
            onUnlockAll: (passphrase) {
              context.read<ArchivePageBloc>().add(
                ArchivePageEvent.decryptFolder(
                  relativePath: folder.relativePath,
                  isPrivate: folder.isPrivate,
                  passphrase: passphrase,
                ),
              );
            },
          ),
    );
  }

  Future<void> _moveSelected() async {
    final bloc = context.read<ArchivePageBloc>();
    final selected =
        _currentImages
            .where((img) => _selectedPaths.contains(img.storagePath.path))
            .toList();
    if (selected.isEmpty) return;

    final isPrivate = selected.first.storagePath.isPrivateFolder;
    final target = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => _MoveTargetSheet(
            allImages: bloc.images,
            isPrivate: isPrivate,
            extraFolders: bloc.folderRelativePaths(isPrivate: isPrivate),
          ),
    );
    if (target != null && mounted) {
      bloc.add(
        ArchivePageEvent.moveImages(
          images: selected,
          targetRelativePath: target,
        ),
      );
      _cancelSelection();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _savedScrollOffset = _scrollController.offset;
    });

    final archiveBloc = context.read<ArchivePageBloc>();

    // The bloc is preserved across archive opens. On a fresh mount, if the bloc
    // is resting in a non-`ui` state (e.g. a `failure` from a rejected
    // duplicate-folder create), re-emit the browsable state from retained data
    // so the `ui`-only BlocBuilders never render blank.
    final isUi = archiveBloc.state.maybeMap(
      ui: (_) => true,
      orElse: () => false,
    );
    if (!isUi) archiveBloc.add(const ArchivePageEvent.refreshView());

    // Restore position after first frame (needs layout to be done)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _savedScrollOffset > 0) {
        _scrollController.jumpTo(_savedScrollOffset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArchivePageBloc, ArchivePageState>(
      listenWhen:
          (p, c) => c.maybeMap(
            failure: (_) => true,
            limitReached: (_) => true,
            orElse: () => false,
          ),
      listener: (context, state) {
        state.mapOrNull(
          failure: (f) => context.showSnackbar(f.message),
          // The free archive cap: an offer, not an error — go sell Pro.
          limitReached: (_) => context.pushNamed(Routes.pro),
        );
      },
      child: BlocBuilder<ArchivePageBloc, ArchivePageState>(
        buildWhen: (p, c) => c.maybeMap(ui: (_) => true, orElse: () => false),
        builder: (context, state) {
          final archiveBloc = context.read<ArchivePageBloc>();
          final canPop =
              !archiveBloc.isSelectionMode &&
              archiveBloc.currentIsPrivate == null &&
              archiveBloc.currentPath.isEmpty;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
            onHorizontalDragEnd: (d) {
              if (!canPop &&
                  (_dragStartX ?? double.infinity) < 50 &&
                  (d.primaryVelocity ?? 0) > 100) {
                _onBack();
              }
              _dragStartX = null;
            },
            child: PopScope(
              canPop: canPop,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                _onBack();
              },
              child: Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: CustomScrollView(
                      cacheExtent: 800,
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(child: const SizedBox(height: 18)),
                        SliverToBoxAdapter(
                          child: _ArchiveHeader(
                            selectedCount: _selectedPaths.length,
                            onCancel: _cancelSelection,
                            onMove: _moveSelected,
                            onDelete: _deleteSelected,
                            onBack: _onBack,
                            onNewFolder: _promptNewFolder,
                            onImport: () => _onImport(context),
                          ),
                        ),
                        const SliverToBoxAdapter(child: _Breadcrumb()),
                        SliverToBoxAdapter(child: const SizedBox(height: 16)),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Row(children: [_EncryptedFilesBadge()]),
                          ),
                        ),
                        _FoldersList(
                          onEnter:
                              (folder) => context.read<ArchivePageBloc>().add(
                                ArchivePageEvent.enterFolder(
                                  relativePath: folder.relativePath,
                                  isPrivate: folder.isPrivate,
                                ),
                              ),
                          onRename: _promptRenameFolder,
                          onDelete: _confirmDeleteFolder,
                          onDecrypt: _decryptFolder,
                        ),
                        _ImagesList(
                          selectedPaths: _selectedPaths,
                          onToggleSelection: _toggleSelection,
                          onActivateSelection: _activateSelection,
                        ),
                      ],
                    ),
                  ),
                ),
                floatingActionButton: const _ArchiveFab(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onBack() {
    final archiveBloc = context.read<ArchivePageBloc>();
    // Read the canonical navigation getters, not the emitted state: mid-operation
    // the state can briefly be non-`ui` (e.g. `decryptingAllUI`), which would
    // otherwise make back exit the archive instead of going up one folder.
    if (archiveBloc.isSelectionMode) {
      _cancelSelection();
      return;
    }
    final notAtRoot =
        archiveBloc.currentIsPrivate != null ||
        archiveBloc.currentPath.isNotEmpty;
    if (notAtRoot) {
      archiveBloc.add(const ArchivePageEvent.goUp());
      return;
    }
    context.pop();
  }

  Future<void> _onImport(BuildContext context) async {
    final assets = await PicturesProvider.pickImagesFromGallery(context);
    if (!context.mounted) return;
    assets.fold(
      (errMessage) {
        if (errMessage != null) context.showSnackbar(errMessage);
      },
      (data) {
        final imported =
            data.map((e) {
              final name = e.title ?? e.id;
              final baseName = (name.contains('.')
                      ? name.split('.').first
                      : name)
                  .replaceAll(" ", "_");
              return ImportImageAsset(asset: e, name: baseName);
            }).toList();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder:
              (_) => BlocProvider.value(
                value: context.read<ArchivePageBloc>(),
                child: _ImportImagesBottomSheet(assets: imported),
              ),
        );
      },
    );
  }

}
