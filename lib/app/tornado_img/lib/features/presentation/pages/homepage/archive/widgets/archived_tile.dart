part of '../archive_page.dart';

class _ArchivedTile extends StatefulWidget {
  const _ArchivedTile({
    required this.image,
    required this.dearchivingStateType,
  });

  final EncryptedImage image;
  final DearchivingStateType? dearchivingStateType;

  @override
  State<_ArchivedTile> createState() => _ArchivedTileState();
}

class _ArchivedTileState extends State<_ArchivedTile> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivePageBloc, ArchivePageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            deleting: (value) => value.paths.contains(widget.image.path),
            orElse: () => false,
          ),
      builder: (context, state) {
        final isDeleting = state.maybeMap(
          deleting: (value) => value.paths.contains(widget.image.path),
          orElse: () => false,
        );

        Widget child;

        if (isDeleting) {
          child = Skeletonizer(child: _content());
        } else {
          child = FilledButton(
            onPressed: () {
              context.push('./encrypted_image_page', extra: widget.image);
            },
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
                    ArchivePageEvent.delete(
                      path: widget.image.path,
                      assetId: widget.image.assetId,
                    ),
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
    Widget icon = ContainedItem.icon(icon: Icons.lock_rounded);

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
      children: [
        _image(),
        Expanded(child: _details()),
        icon,
      ],
    );
  }

  Widget _image() {
    final bytes =
        widget.image.decryptInfo?.bytes ?? widget.image.encryptedInfo.bytes;
    final isDecrypted = widget.image.decryptInfo != null;

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

    String visiblePath = widget.image.file.parent.path;
    if (widget.image.isPrivateFolder) {
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
