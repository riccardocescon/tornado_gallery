part of '../fullscreen_media_viewer.dart';

/// One page of the pager: the video surface when this page owns the controller,
/// the zoomable bitmap for images.
class _MediaPage extends StatelessWidget {
  const _MediaPage({
    super.key,
    required this.item,
    required this.controller,
    required this.onZoomChanged,
  });

  final EncryptedImage item;

  /// Null while the page is off-screen or still initializing — the viewer keeps
  /// a single controller, for the current page.
  final VideoPlayerController? controller;
  final ValueChanged<bool> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    if (!item.isVideo) {
      return ZoomableView(
        onZoomChanged: onZoomChanged,
        child: Image.memory(
          item.decryptInfo!.bytes,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      );
    }

    final controller = this.controller;
    if (controller == null) {
      // A bulk decrypt leaves the unscrambled poster in `decryptInfo`; without
      // it, black — never `encryptedInfo`, which is the *scrambled* poster.
      final poster = item.decryptInfo?.bytes;
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          if (poster != null) Center(child: Image.memory(poster)),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return ZoomableView(
      // The double tap belongs to `_TapZones` (±10s), so pinch only here.
      doubleTapToZoom: false,
      onZoomChanged: onZoomChanged,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}
