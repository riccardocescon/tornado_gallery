part of '../fullscreen_media_viewer.dart';

/// Left/right halves of the video: single tap toggles the chrome, double tap
/// jumps [step] back or forward with a short badge on that side.
///
/// Translucent hit behaviour on purpose — the pager underneath still gets its
/// horizontal drags, so swiping to the next item keeps working.
///
/// ponytail: no cumulative counter (+10/+20/+30 on repeated taps). Each double
/// tap is one [step] from the current position; add the accumulator if the
/// single jump ever feels short.
class _TapZones extends StatefulWidget {
  const _TapZones({
    required this.onTap,
    required this.onSkip,
    required this.step,
  });

  final VoidCallback onTap;
  final ValueChanged<Duration> onSkip;
  final Duration step;

  @override
  State<_TapZones> createState() => _TapZonesState();
}

class _TapZonesState extends State<_TapZones> {
  static const _badgeDuration = Duration(milliseconds: 600);

  /// -1 = rewind badge, 1 = forward badge, null = none.
  int? _badgeSide;
  Timer? _badgeTimer;

  @override
  void dispose() {
    _badgeTimer?.cancel();
    super.dispose();
  }

  void _skip(int side) {
    widget.onSkip(widget.step * side);
    setState(() => _badgeSide = side);
    _badgeTimer?.cancel();
    _badgeTimer = Timer(_badgeDuration, () {
      if (mounted) setState(() => _badgeSide = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // Stretch, or each zone would only be as tall as its badge.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _zone(-1, Icons.fast_rewind_rounded)),
        Expanded(child: _zone(1, Icons.fast_forward_rounded)),
      ],
    );
  }

  Widget _zone(int side, IconData icon) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onDoubleTap: () => _skip(side),
      // Ignoring, or the badge would be a hit target even at opacity 0 and eat
      // swipes that start dead centre — where they usually do.
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _badgeSide == side ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Center(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    Text(
                      '${widget.step.inSeconds}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
