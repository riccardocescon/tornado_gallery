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

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final ScrollController _scrollController = ScrollController();
  static double _savedScrollOffset = 0;
  List<EncryptedImage> _lastUiImages = [];
  double? _dragStartX;

  final Set<String> _selectedPaths = {};

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
        _lastUiImages
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
        borderRadius: BorderRadius.vertical(top: AppStyle.cardBorderRadius.topLeft),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                    onSelectionChanged: (s) =>
                        setSheetState(() => isPrivate = s.first),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pop(ctx, (controller.text, isPrivate)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      builder: (ctx) => AlertDialog(
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
      builder: (ctx) => AlertDialog(
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
      builder: (_) => UnlockAllBottomSheet(
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
    final selected = _lastUiImages
        .where((img) => _selectedPaths.contains(img.storagePath.path))
        .toList();
    if (selected.isEmpty) return;

    final isPrivate = selected.first.storagePath.isPrivateFolder;
    final target = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MoveTargetSheet(
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

    // Set _lastUiImages if the latest state was dearchiving all
    // so it can show the deachivedAll icons correctly
    context.read<ArchivePageBloc>().state.mapOrNull(
      decryptingAllUI:
          (value) => _lastUiImages = value.dearchivingState.allImages,
    );

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
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (p, c) => c.maybeMap(ui: (_) => true, orElse: () => false),
      builder: (context, state) {
        final canPop = state.maybeMap(
          ui: (s) =>
              !s.isSelectionMode &&
              s.currentIsPrivate == null &&
              s.currentPath.isEmpty,
          orElse: () => false,
        );
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
                    SliverToBoxAdapter(child: _header()),
                    SliverToBoxAdapter(child: _breadcrumb()),
                    SliverToBoxAdapter(child: const SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Row(children: [_encryptedFiles()]),
                      ),
                    ),
                    _folders(),
                    _images(),
                  ],
                ),
              ),
            ),
            floatingActionButton: _fab(),
          ),
          ),
        );
      },
    );
  }

  void _onBack() {
    final archiveBloc = context.read<ArchivePageBloc>();
    final inSelection = archiveBloc.state.maybeMap(
      ui: (s) => s.isSelectionMode,
      orElse: () => false,
    );
    if (inSelection) {
      _cancelSelection();
      return;
    }
    final notAtRoot = archiveBloc.state.maybeMap(
      ui: (s) => s.currentIsPrivate != null || s.currentPath.isNotEmpty,
      orElse: () => false,
    );
    if (notAtRoot) {
      archiveBloc.add(const ArchivePageEvent.goUp());
      return;
    }
    context.pop();
  }

  Widget _fab() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            decryptingAllUI: (value) => true,
            ui: (value) => true,
            orElse: () => false,
          ),
      builder: (context, state) {
        final archiveBloc = context.read<ArchivePageBloc>();
        final isDecrypting = archiveBloc.isDecryptingAllImages;
        final hasDecryptedAll = archiveBloc.hasAllDecrypted;

        // No images at the current navigation level → nothing to
        // decrypt/encrypt here, hide the FAB.
        if (archiveBloc.currentFolderImages.isEmpty && !isDecrypting) {
          return const SizedBox.shrink();
        }

        final isLoading = state.maybeMap(
          decryptingAllUI:
              (value) =>
                  value.dearchivingState.totalImages !=
                  value.dearchivingState.progress,
          orElse: () => isDecrypting && !hasDecryptedAll,
        );

        if (isLoading) return const SizedBox.shrink();

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

  Widget _header() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (previous, current) => current.maybeMap(
        ui: (_) => true,
        orElse: () => false,
      ),
      builder: (context, state) {
        final isSelectionMode =
            state.maybeMap(ui: (s) => s.isSelectionMode, orElse: () => false);

        if (isSelectionMode) {
          return Row(
            children: [
              TextButton(
                onPressed: _cancelSelection,
                child: const Text("Cancel"),
              ),
              const Spacer(),
              Text(
                "${_selectedPaths.length} selected",
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _selectedPaths.isEmpty ? null : _moveSelected,
                icon: Icon(
                  Icons.drive_file_move_outline,
                  color: _selectedPaths.isEmpty
                      ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                      : context.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: _selectedPaths.isEmpty ? null : _deleteSelected,
                icon: Icon(
                  Icons.delete_rounded,
                  color: _selectedPaths.isEmpty
                      ? context.colorScheme.onSurface.withValues(alpha: 0.3)
                      : context.colorScheme.error,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageTitle(
                title: "Archive",
                subtitle: "View and manage your archived images",
                icon: Icons.archive,
              ),
            ),
              IconButton(
                onPressed: _onBack,
                icon: const Icon(Icons.drive_folder_upload_rounded),
              ),
            IconButton(
              tooltip: "New folder",
              onPressed: _promptNewFolder,
              icon: Icon(
                Icons.create_new_folder_outlined,
                color: context.colorScheme.onSurface,
              ),
            ),
            IconButton(
              tooltip: "Import",
              onPressed: () => _onImport(context),
              icon: Icon(
                Icons.upload_file_rounded,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onImport(BuildContext context) async {
    final assets = await PicturesProvider.pickImagesFromGallery(context);
    if (!context.mounted) return;
    assets.fold(
      (errMessage) {
        if (errMessage != null) context.showSnackbar(errMessage);
      },
      (data) {
        final imported = data.map((e) {
          final name = e.title ?? e.id;
          final baseName =
              (name.contains('.') ? name.split('.').first : name)
                  .replaceAll(" ", "_");
          return ImportImageAsset(asset: e, name: baseName);
        }).toList();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => BlocProvider.value(
            value: context.read<ArchivePageBloc>(),
            child: _ImportImagesBottomSheet(assets: imported),
          ),
        );
      },
    );
  }

  Widget _breadcrumb() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (previous, current) => current.maybeMap(
        ui: (_) => true,
        orElse: () => false,
      ),
      builder: (context, state) {
        final breadcrumb =
            state.maybeMap(ui: (s) => s.breadcrumb, orElse: () => <String>[]);
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

  Widget _folders() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (previous, current) => current.maybeMap(
        ui: (_) => true,
        orElse: () => false,
      ),
      builder: (context, state) {
        final folders = state.maybeMap(
          ui: (s) => s.folders,
          orElse: () => <ArchiveFolderView>[],
        );
        if (folders.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverList.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return _ArchiveFolderTile(
              folder: folder,
              onTap: () => context.read<ArchivePageBloc>().add(
                ArchivePageEvent.enterFolder(
                  relativePath: folder.relativePath,
                  isPrivate: folder.isPrivate,
                ),
              ),
              onRename: () => _promptRenameFolder(folder),
              onDelete: () => _confirmDeleteFolder(folder),
              onDecrypt: () => _decryptFolder(folder),
            );
          },
        );
      },
    );
  }

  Widget _images() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (previous, current) => current.maybeMap(
        ui: (_) => true,
        decryptingAllUI: (s) =>
            _lastUiImages.length == s.dearchivingState.totalImages,
        orElse: () => false,
      ),
      builder: (context, state) {
        return state.maybeMap(
          ui: (s) {
            final images = s.images;
            _lastUiImages = images;
            if (images.isEmpty) {
              return SliverToBoxAdapter(
                child: s.folders.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: _noImages(),
                      )
                    : const SizedBox.shrink(),
              );
            }

            return SliverList.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Column(
                  children: [
                    _ArchivedTile(
                      image: image,
                      dearchivingStateType: null,
                      isSelectionMode: s.isSelectionMode,
                      isSelected:
                          _selectedPaths.contains(image.storagePath.path),
                      onToggleSelection:
                          () => _toggleSelection(image.storagePath.path),
                      onActivateSelection: () => _activateSelection(image),
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
          decryptingAllUI: (s) {
            final dearchivingState = s.dearchivingState;
            assert(_lastUiImages.length == dearchivingState.totalImages);

            return SliverList.builder(
              itemCount: dearchivingState.totalImages,
              itemBuilder: (context, index) {
                final image = dearchivingState.allImages.firstWhere(
                  (e) =>
                      e.storagePath.path ==
                      _lastUiImages[index].storagePath.path,
                );
                final tileState =
                    dearchivingState.getState(image.storagePath.path);

                return Column(
                  children: [
                    _ArchivedTile(image: image, dearchivingStateType: tileState),
                    if (index != _lastUiImages.length - 1)
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
          orElse: () => SliverFillRemaining(child: _noImages()),
        );
      },
    );
  }

  Widget _noImages() {
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

  Widget _encryptedFiles() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen: (previous, current) => current.maybeMap(
        ui: (_) => true,
        orElse: () => false,
      ),
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
                  color: context.isDarkMode
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
