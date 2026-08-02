/// Time helpers for the video player chrome.
library;

/// `m:ss`, or `h:mm:ss` once past an hour. Negatives clamp to zero.
String formatDuration(Duration d) {
  final total = d.isNegative ? Duration.zero : d;
  final seconds = (total.inSeconds % 60).toString().padLeft(2, '0');

  if (total.inHours == 0) return '${total.inMinutes}:$seconds';

  final minutes = (total.inMinutes % 60).toString().padLeft(2, '0');
  return '${total.inHours}:$minutes:$seconds';
}

/// [current] + [delta], clamped to `0..total` — the ±10s double-tap and the
/// skip buttons both go through here so neither can seek past either end.
Duration seekBy(Duration current, Duration delta, Duration total) =>
    clampSeekTarget(current + delta, total);

/// How far before the end a seek target is allowed to land.
const _endGuard = Duration(milliseconds: 250);

/// Keeps a seek target inside `0..total`, and never *at* [total].
///
/// `seekTo(duration)` sets `isCompleted` on the controller, and the plugin's
/// `play()` then does `if (position == duration) seekTo(Duration.zero)` — so
/// scrubbing to the far right and releasing would restart from the beginning or
/// sit frozen on the last frame. Every seek target in the player goes through
/// here.
Duration clampSeekTarget(Duration target, Duration total) {
  if (target.isNegative) return Duration.zero;
  final last = total - _endGuard;
  // Clip shorter than the guard: land at zero rather than negative.
  if (last.isNegative) return Duration.zero;
  return target > last ? last : target;
}
