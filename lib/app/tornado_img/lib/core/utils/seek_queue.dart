/// Serializes seeks: one in flight, the latest target wins.
///
/// `VideoPlayerController.seekTo` has no in-flight guard and no coalescing, and
/// its `await` returns as soon as the platform *method call* returns — on
/// Android the handler is a bare `exoPlayer.seekTo(position)`. Fire one seek per
/// drag update and ExoPlayer ends up running several exact seeks at once, stops
/// rendering, and the picture freezes.
///
/// This is not a time-based throttle: intermediate targets are **dropped**, not
/// queued, so the rate is set by the player itself — a slow seek simply means
/// fewer seeks. [requested] and [issued] exist so a caller can log how much was
/// collapsed.
class SeekQueue {
  SeekQueue(this._seek);

  final Future<void> Function(Duration target) _seek;

  Duration? _pending;
  Future<void>? _draining;

  int _requested = 0;
  int _issued = 0;

  /// Seeks asked for, including the ones dropped without being sent.
  int get requested => _requested;

  /// Seeks actually handed to the player.
  int get issued => _issued;

  /// True while a seek is in flight.
  bool get isSeeking => _draining != null;

  /// Asks for [target]. The returned future completes when the queue has
  /// drained — i.e. when the **last** position requested has been sent to the
  /// player, which is the moment it is safe to resume playback.
  Future<void> request(Duration target) {
    _requested++;
    _pending = target;
    return _draining ??= _drain();
  }

  Future<void> _drain() async {
    // _pending is non-null on entry (request just set it), so the loop always
    // suspends at the first await before `_draining` is cleared below.
    while (_pending != null) {
      final next = _pending!;
      _pending = null;
      _issued++;
      await _seek(next);
    }
    _draining = null;
  }
}
