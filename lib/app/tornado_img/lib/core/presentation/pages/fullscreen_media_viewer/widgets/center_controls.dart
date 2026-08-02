part of '../fullscreen_media_viewer.dart';

/// `⏪10 · ▶/⏸ · ⏩10`, centred over the video while the chrome is up.
class _CenterControls extends StatelessWidget {
  const _CenterControls({
    required this.controller,
    required this.step,
    required this.onTogglePlayback,
    required this.onSkip,
  });

  final VideoPlayerController controller;
  final Duration step;
  final VoidCallback onTogglePlayback;
  final ValueChanged<Duration> onSkip;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
              onPressed: () => onSkip(-step),
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 72,
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                color: Colors.white,
              ),
              onPressed: onTogglePlayback,
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
              onPressed: () => onSkip(step),
            ),
          ],
        );
      },
    );
  }
}
