part of '../archive_page.dart';

class _ArchivedTile extends StatefulWidget {
  const _ArchivedTile({
    required this.image,
    required this.dearchivingStateType,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
    this.onActivateSelection,
  });

  final EncryptedImage image;
  final DearchivingStateType? dearchivingStateType;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;
  final VoidCallback? onActivateSelection;

  @override
  State<_ArchivedTile> createState() => _ArchivedTileState();
}

class _ArchivedTileState extends State<_ArchivedTile> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            deleting:
                (value) => value.paths.contains(widget.image.storagePath.path),
            ui:
                (value) => value.images.any(
                  (img) =>
                      img.storagePath.path == widget.image.storagePath.path,
                ),
            orElse: () => false,
          ),
      builder: (context, state) {
        final isDeleting = state.maybeMap(
          deleting:
              (value) => value.paths.contains(widget.image.storagePath.path),
          orElse: () => false,
        );

        Widget child;

        if (isDeleting) {
          child = Skeletonizer(child: _content());
        } else if (widget.isSelectionMode) {
          child = GestureDetector(
            onTap: widget.onToggleSelection,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? context.colorScheme.primary.withValues(alpha: 0.12)
                        : context.appColors.scaffoldBackground,
                borderRadius: AppStyle.detailsBorderRadius,
              ),
              child: Row(
                children: [
                  Expanded(child: _content()),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onToggleSelection?.call(),
                  ),
                ],
              ),
            ),
          );
        } else {
          child = FilledButton(
            onPressed: () {
              context.pushNamed(
                widget.image.isVideo
                    ? Routes.videoPlayer
                    : Routes.encryptedImagePage,
                extra: widget.image,
              );
            },
            onLongPress: widget.onActivateSelection,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: AppStyle.detailsBorderRadius,
              ),
              backgroundColor: context.appColors.scaffoldBackground,
              overlayColor: context.colorScheme.onSurface.withValues(
                alpha: 0.05,
              ),
            ),
            child: _content(),
          );
        }

        if (widget.isSelectionMode) {
          return SizedBox(height: 80 + 32, child: child);
        }

        return SizedBox(
          height: 80 + 32,
          child: FocusedMenuHolder(
            openWithTap: false,
            onPressed: () {},
            menuOffset: 4,
            menuItems: [
              FocusedMenuItem(
                title: Text(
                  "Delete",
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
                onPressed: () {
                  context.read<ArchivePageBloc>().add(
                    ArchivePageEvent.delete(images: [widget.image]),
                  );
                },
                trailingIcon: Icon(
                  Icons.delete_rounded,
                  color: context.colorScheme.error,
                ),
              ),
            ],
            child: child,
          ),
        );
      },
    );
  }

  Widget _content() {
    Widget icon = ContainedItem.icon(
      icon:
          widget.image.decryptInfo == null
              ? Icons.lock_rounded
              : Icons.lock_open_rounded,
    );

    if (widget.dearchivingStateType != null) {
      icon = switch (widget.dearchivingStateType!) {
        DearchivingStateType.loading => ContainedItem.widget(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
        DearchivingStateType.dearchived => ContainedItem.icon(
          icon: Icons.lock_open_rounded,
        ),
        DearchivingStateType.failure => ContainedItem.icon(
          icon: Icons.error_rounded,
          backgroundColor: context.colorScheme.error.withValues(alpha: 0.1),
          iconColor: context.colorScheme.error,
        ),
      };
    }

    return Row(
      spacing: 16,
      children: [_image(), Expanded(child: _details()), icon],
    );
  }

  Widget _image() {
    final bytes =
        widget.image.decryptInfo?.bytes ?? widget.image.encryptedInfo.bytes;
    final isDecrypted = widget.image.decryptInfo != null;

    // A video's preview bytes are already the scrambled poster frame (see
    // the poster box in video_box_codec.dart), so it needs no zoom — only the
    // play hint that tells it apart from a still.
    if (widget.image.isVideo) {
      return ClipRRect(
        borderRadius: AppStyle.detailsBorderRadius,
        child: SizedBox(
          width: 56,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 24,
                  color: context.appColors.onAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppStyle.detailsBorderRadius,
      child: Transform.scale(
        scale:
            isDecrypted
                ? 1
                : bytes.lengthInBytes > 10000000
                ? 30
                : 10,
        child: Image.memory(bytes, width: 56, height: 80, fit: BoxFit.cover),
      ),
    );
  }

  Widget _details() {
    String date = '';
    final now = DateTime.now();
    if (widget.image.date.day == now.day &&
        widget.image.date.month == now.month &&
        widget.image.date.year == now.year) {
      date = "Today";
    } else if (widget.image.date.day == now.day - 1 &&
        widget.image.date.month == now.month &&
        widget.image.date.year == now.year) {
      date = "Yesterday";
    } else {
      date = DateFormat("dd/MM/yyyy").format(widget.image.date);
    }

    date += " at ${DateFormat("HH:mm").format(widget.image.date)}";

    String visiblePath = widget.image.storagePath.file.parent.path;
    if (widget.image.storagePath.isPrivateFolder) {
      visiblePath = visiblePath.split("encrypted").last;
      visiblePath = "../encrypted$visiblePath/${widget.image.name}";
    } else {
      visiblePath = visiblePath.split("TornadoGallery").last;
      visiblePath = "../TornadoGallery$visiblePath/${widget.image.name}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.image.name,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              Expanded(
                child: Text(
                  visiblePath,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
