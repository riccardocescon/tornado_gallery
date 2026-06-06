import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/utils/pictures_provider.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/dearchiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/import_image_asset.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/core/utils/file_name_validator.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';

part 'widgets/archived_tile.dart';
part 'widgets/import_images_bottom_sheet.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final ScrollController _scrollController = ScrollController();
  static double _savedScrollOffset = 0;
  List<EncryptedImage> _lastUiImages = [];

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: CustomScrollView(
        cacheExtent: 800,
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: BlocBuilder<ArchivePageBloc, ArchivePageState>(
              buildWhen:
                  (previous, current) => current.maybeWhen(
                    ui:
                        (images, isSelectionMode) => previous.maybeWhen(
                          ui: (_, prevMode) => prevMode != isSelectionMode,
                          orElse: () => true,
                        ),
                    orElse: () => false,
                  ),
              builder: (context, state) {
                final isSelectionMode = state.maybeWhen(
                  ui: (_, mode) => mode,
                  orElse: () => false,
                );
                return isSelectionMode
                    ? Row(
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
                          onPressed:
                              _selectedPaths.isEmpty ? null : _deleteSelected,
                          icon: Icon(
                            Icons.delete_rounded,
                            color:
                                _selectedPaths.isEmpty
                                    ? context.colorScheme.onSurface.withValues(
                                      alpha: 0.3,
                                    )
                                    : context.colorScheme.error,
                          ),
                        ),
                      ],
                    )
                    : Row(
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
                          onPressed: () async {
                            final assets =
                                await PicturesProvider.pickImagesFromGallery(
                                  context,
                                );

                            assets.fold(
                              (errMessage) {
                                if (errMessage != null) {
                                  context.showSnackbar(errMessage);
                                }
                              },
                              (data) {
                                final assets =
                                    data.map((e) {
                                      final name = e.title ?? e.id;
                                      final baseName = (name.contains('.')
                                              ? name.split('.').first
                                              : name)
                                          .replaceAll(" ", "_");

                                      return ImportImageAsset(
                                        asset: e,
                                        name: baseName,
                                      );
                                    }).toList(); 
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) {
                                    return BlocProvider.value(
                                      value: context.read<ArchivePageBloc>(),
                                      child: _ImportImagesBottomSheet(
                                        assets: assets,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.upload_file_rounded,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    );
              },
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SizedBox(
              width: double.maxFinite,
              child: Row(children: [_encryptedFiles()]),
            ),
          ),
          _images(),
        ],
      ),
    );
  }

  Widget _images() {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) => current.maybeWhen(
            ui: (images, isSelectionMode) => true,
            decryptingAllUI: (dearchivingState) => true,
            orElse: () => false,
          ),
      builder: (context, state) {
        return state.maybeWhen(
          ui: (images, isSelectionMode) {
            _lastUiImages = images;
            if (images.isEmpty) {
              return SliverFillRemaining(child: _noImages());
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
                      isSelectionMode: isSelectionMode,
                      isSelected: _selectedPaths.contains(
                        image.storagePath.path,
                      ),
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
          decryptingAllUI: (dearchivingState) {
            assert(_lastUiImages.length == dearchivingState.totalImages);

            return SliverList.builder(
              itemCount: dearchivingState.totalImages,
              itemBuilder: (context, index) {
                final image = dearchivingState.allImages.firstWhere(
                  (e) =>
                      e.storagePath.path ==
                      _lastUiImages[index].storagePath.path,
                );
                final state = dearchivingState.getState(image.storagePath.path);

                return Column(
                  children: [
                    _ArchivedTile(image: image, dearchivingStateType: state),
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
      buildWhen:
          (previous, current) => current.maybeWhen(
            ui:
                (images, isSelectionMode) => previous.maybeWhen(
                  ui: (prevImages, _) => prevImages.length != images.length,
                  orElse: () => true,
                ),
            orElse: () => false,
          ),
      builder: (context, state) {
        return state.maybeWhen(
          ui: (images, _) {
            final encryptedCount = images.length;
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
