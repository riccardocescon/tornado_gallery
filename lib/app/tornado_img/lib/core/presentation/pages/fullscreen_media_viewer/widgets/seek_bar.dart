part of '../fullscreen_media_viewer.dart';

/// The scrub bar: a stock [Slider] with a fat track and a big overlay, so it is
/// actually grabbable with a thumb.
///
/// Dragging seeks the real player — that is what makes the picture follow the
/// finger frame by frame; the plaintext is a local file, so a platform seek
/// lands in ms and no thumbnail strip is generated or cached anywhere.
///
/// Two things keep the seeks survivable, and **both** are needed:
///
/// * a wall-clock floor between seeks ([_minSeekInterval], with a trailing timer
///   so the final position always lands). Serializing on `await seekTo` is not
///   enough and measurements said so: 261 drag updates produced 241 issued
///   seeks, because the Android handler is `exoPlayer.seekTo(pos)` and the
///   platform call returns before the seek happens — the await gives zero
///   back-pressure. Those 241 *exact* seeks (the plugin never sets
///   `CLOSEST_SYNC`) wedged ExoPlayer in `buffering=true` with the position
///   frozen, and `play()` never recovered it.
/// * **not pausing** during the drag. A playing ExoPlayer has to keep its
///   pipeline hot, so seeks land visibly and it recovers on its own; a paused
///   one that gets wedged mid-scrub stays wedged. The audio is muted for the
///   duration instead, which is what the pause was really for.
///
/// [SeekQueue] stays on top of that to collapse anything still overlapping.
///
/// This widget owns the **whole** gesture, from raw pointer down to up. The
/// `Listener` is what tells the viewer to freeze paging (the bar and the pager
/// are siblings fighting over the same horizontal drag, and the slider's
/// `onChangeStart` fires too late — the page already has the pointer). Pointer
/// up *and cancel* both resume: hanging the resume off `Slider.onChangeEnd`
/// meant a cancelled pointer left the video paused forever.
class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.controller, required this.onScrubbing});

  final VideoPlayerController controller;

  /// Raised on pointer down, lowered on pointer up/cancel.
  final ValueChanged<bool> onScrubbing;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  late final SeekQueue _queue = SeekQueue(widget.controller.seekTo);

  /// Floor between two seeks while dragging. ~4 previews a second reads as
  /// "the picture follows the finger" and keeps the decoder alive; 12+ a second
  /// is what wedged it.
  static const _minSeekInterval = Duration(milliseconds: 250);

  /// Non-null while dragging: the slider follows the finger, not the player, so
  /// it never snaps back on a slow seek.
  double? _dragMs;
  bool _wasPlaying = false;
  double _volume = 1;

  /// Throttle state: the newest target not yet handed to the player, plus the
  /// timer that flushes it once the floor has passed.
  double? _pendingMs;
  Timer? _trailing;
  final _sinceIssue = Stopwatch();

  @override
  void dispose() {
    _trailing?.cancel();
    super.dispose();
  }

  void _onPointerDown() {
    final value = widget.controller.value;
    _wasPlaying = value.isPlaying;
    _volume = value.volume;
    // Playing, not paused — see the class doc. Muted so the scrub isn't audible.
    widget.controller.setVolume(0);
    widget.onScrubbing(true);
  }

  Future<void> _onPointerFinished() async {
    _trailing?.cancel();
    _trailing = null;
    final target = _dragMs;
    widget.onScrubbing(false);

    // The final position skips the throttle: it must land whatever the timing.
    if (target != null) await _queue.request(_seekTarget(target));
    if (!mounted) return;

    _pendingMs = null;
    _sinceIssue.stop();
    setState(() => _dragMs = null);
    await widget.controller.setVolume(_volume);
    // Playback was never stopped; this only corrects a player that something
    // else paused under us (the plugin's `completed` handler does that).
    if (_wasPlaying && !widget.controller.value.isPlaying) {
      await widget.controller.play();
    }
  }

  void _onChanged(double ms) {
    setState(() => _dragMs = ms);
    _pendingMs = ms;
    _flushSeek();
  }

  /// Issues the newest target if the floor has passed, otherwise arms a timer
  /// for the remainder — so a finger that stops moving still gets its frame.
  void _flushSeek() {
    final waited = _sinceIssue.elapsed;
    if (_sinceIssue.isRunning && waited < _minSeekInterval) {
      _trailing ??= Timer(_minSeekInterval - waited, () {
        _trailing = null;
        _flushSeek();
      });
      return;
    }

    final target = _pendingMs;
    if (target == null) return;
    _pendingMs = null;
    _sinceIssue
      ..reset()
      ..start();
    _queue.request(_seekTarget(target));
  }

  Duration _seekTarget(double ms) => clampSeekTarget(
    Duration(milliseconds: ms.round()),
    widget.controller.value.duration,
  );

  @override
  Widget build(BuildContext context) {
    final accent = context.appColors.accent;

    return Listener(
      onPointerDown: (_) => _onPointerDown(),
      onPointerUp: (_) => _onPointerFinished(),
      onPointerCancel: (_) => _onPointerFinished(),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, _) {
          final totalMs = value.duration.inMilliseconds.toDouble();
          if (totalMs <= 0) return const SizedBox.shrink();

          final positionMs = (_dragMs ??
                  value.position.inMilliseconds.toDouble())
              .clamp(0.0, totalMs);
          final bufferedMs = _bufferedMs(value).clamp(positionMs, totalMs);

          return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
            child: Row(
              children: [
                _label(
                  formatDuration(Duration(milliseconds: positionMs.round())),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 22,
                      ),
                      activeTrackColor: accent,
                      inactiveTrackColor: Colors.white24,
                      secondaryActiveTrackColor: Colors.white38,
                      thumbColor: accent,
                      overlayColor: accent.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: positionMs,
                      // Free buffered track — no custom painter needed.
                      secondaryTrackValue: bufferedMs,
                      max: totalMs,
                      onChanged: _onChanged,
                    ),
                  ),
                ),
                _label(formatDuration(value.duration)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// End of the last buffered range, 0 when nothing is buffered yet.
  double _bufferedMs(VideoPlayerValue value) {
    if (value.buffered.isEmpty) return 0;
    return value.buffered.last.end.inMilliseconds.toDouble();
  }
}
