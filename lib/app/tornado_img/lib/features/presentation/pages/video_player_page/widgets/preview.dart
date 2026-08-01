part of '../video_player_page.dart';

/// The 300px-tall media box: the scrambled poster while locked, the player once
/// decrypted. Tapping the player opens [FullscreenVideoViewer] on the same
/// controller.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.image,
    required this.controller,
    required this.decrypting,
  });

  final EncryptedImage image;
  final VideoPlayerController? controller;
  final bool decrypting;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;

    if (controller == null) {
      // Before decryption there is nothing to play — show the same scrambled
      // poster the archive tile shows, with the cosmetic clip's play hint.
      return ClipRRect(
        borderRadius: AppStyle.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(image.encryptedInfo.bytes, fit: BoxFit.cover),
            if (decrypting)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: context.appColors.onAccent,
                ),
              ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppStyle.cardBorderRadius,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          VideoProgressIndicator(controller, allowScrubbing: true),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      fullscreenDialog: true,
                      builder:
                          (_) => FullscreenVideoViewer(
                            controller: controller,
                            title: image.name,
                          ),
                    ),
                  ),
              onDoubleTap:
                  () =>
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play(),
            ),
          ),
        ],
      ),
    );
  }
}
