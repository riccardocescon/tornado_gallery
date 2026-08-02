part of '../video_player_page.dart';

/// The 300px-tall media box: the scrambled poster while locked, a still frame of
/// the decrypted video once unlocked.
///
/// It deliberately does not play or scrub — tapping opens
/// [FullscreenMediaViewer], which owns every playback control. One place with a
/// player, instead of two half-players fighting over the same texture.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.image,
    required this.controller,
    required this.decrypting,
    required this.onOpen,
  });

  final EncryptedImage image;
  final VideoPlayerController? controller;
  final bool decrypting;
  final VoidCallback onOpen;

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 64,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
