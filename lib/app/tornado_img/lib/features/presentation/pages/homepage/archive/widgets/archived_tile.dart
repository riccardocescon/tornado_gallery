part of '../archive_page.dart';

class _ArchivedTile extends StatefulWidget {
  const _ArchivedTile({required this.image});

  final EncryptedImage image;

  @override
  State<_ArchivedTile> createState() => _ArchivedTileState();
}

class _ArchivedTileState extends State<_ArchivedTile> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80 + 32,
      child: FilledButton(
        onPressed: () {
          context.push('./encrypted_image_page', extra: widget.image);
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: AppStyle.detailsBorderRadius,
          ),
          backgroundColor: context.appColors.scaffoldBackground,
          overlayColor: context.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        child: Row(
          spacing: 16,
          children: [
            _image(),
            Expanded(child: _details()),
            ContainedIcon(icon: Icons.lock_rounded),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    final bytes =
        widget.image.decryptInfo?.bytes ?? widget.image.encryptedInfo.bytes;
    
    return ClipRRect(
      borderRadius: AppStyle.detailsBorderRadius,
      child: Transform.scale(
        scale: bytes.lengthInBytes > 10000000 ? 30 : 10,
                  child: Image.memory(
                    bytes,
                    width: 56,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
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

    String visiblePath = widget.image.file.path;
    visiblePath = visiblePath.split("encrypted").last;
    visiblePath = ".../encrypted$visiblePath";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.image.file.path.split("/").last,
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
