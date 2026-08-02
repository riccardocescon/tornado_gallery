import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';
import 'package:tornado_img_app/core/presentation/widgets/zoomable_view.dart';
import 'package:tornado_img_app/core/utils/duration_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/utils/seek_queue.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:video_player/video_player.dart';

part 'widgets/media_page.dart';
part 'widgets/seek_bar.dart';
part 'widgets/center_controls.dart';
part 'widgets/tap_zones.dart';

/// Fullscreen player for already-unlocked media: this is where the video
/// controls live, the detail page only shows a still frame.
///
/// Horizontal swipe pages through [items] — videos and images mixed, same order
/// the archive shows. Only items that can actually be rendered belong in that
/// list; build it with [playable].
///
/// Video controllers are owned **here**, one at a time, for the current page:
/// two `VideoPlayer` widgets can't share one texture, and paging needs a fresh
/// controller per file anyway. Positions flow back through
/// [DecryptedVideoCache.savePosition] on every page change and on dispose, so
/// resume keeps working exactly as it did before.
class FullscreenMediaViewer extends StatefulWidget {
  const FullscreenMediaViewer({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.videoCache,
  }) : assert(items.length > 0, 'nothing to show');

  final List<EncryptedImage> items;
  final int initialIndex;
  final DecryptedVideoCache videoCache;

  /// The subset of [items] this viewer can render: images holding plaintext
  /// bytes, and videos whose plaintext temp file is still in [cache].
  ///
  /// Locked items are dropped rather than shown behind a password field —
  /// there is no app-wide passphrase, so unlocking mid-swipe would mean a
  /// prompt inside the fullscreen chrome.
  static List<EncryptedImage> playable(
    List<EncryptedImage> items,
    DecryptedVideoCache cache,
  ) {
    return items
        .where(
          (item) =>
              item.isVideo
                  ? cache.entry(item.storagePath.path) != null
                  : item.decryptInfo != null,
        )
        .toList();
  }

  @override
  State<FullscreenMediaViewer> createState() => _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends State<FullscreenMediaViewer>
    with SingleTickerProviderStateMixin {
  static const _hideDuration = Duration(seconds: 3);
  static const _skipStep = Duration(seconds: 10);
  static const _speeds = <double>[0.5, 0.75, 1, 1.25, 1.5, 2];

  late final PageController _pageController;
  late final AnimationController _chromeAnimController;
  late int _currentIndex;

  bool _chromeVisible = true;
  Timer? _hideTimer;

  /// Both freeze paging: a scrub drag and a pinch-zoomed image would otherwise
  /// turn the page instead.
  bool _scrubbing = false;
  bool _isZoomed = false;

  bool _landscape = false;
  double _speed = 1;

  VideoPlayerController? _controller;
  EncryptedImage? _controllerItem;

  /// Guards against a fast swipe: an [_openVideo] that finished initializing
  /// after the user already moved on must throw its controller away.
  int _openToken = 0;

  EncryptedImage get _current => widget.items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _chromeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _scheduleHide();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (_current.isVideo) unawaited(_openVideo(_current));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _chromeAnimController.dispose();
    _pageController.dispose();
    _releaseController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  // ---------------------------------------------------------------- controller

  Future<void> _openVideo(EncryptedImage item) async {
    final cached = widget.videoCache.entry(item.storagePath.path);
    if (cached == null) return;

    final token = ++_openToken;
    final controller = VideoPlayerController.file(cached.file);
    try {
      await controller.initialize();
    } catch (e) {
      await controller.dispose();
      appLogger.log(
        'Fullscreen playback init failed',
        LogLayer.ui,
        error: '$e',
      );
      return;
    }

    if (!mounted || token != _openToken) {
      await controller.dispose();
      return;
    }

    if (cached.position > Duration.zero) {
      await controller.seekTo(cached.position);
    }
    await controller.setLooping(true);
    await controller.setPlaybackSpeed(_speed);
    await controller.play();

    if (!mounted || token != _openToken) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _controllerItem = item;
    });
  }

  /// Hands the position back to the cache, then drops the controller.
  void _releaseController() {
    final controller = _controller;
    final item = _controllerItem;
    _controller = null;
    _controllerItem = null;
    if (controller == null) return;
    if (item != null) {
      widget.videoCache.savePosition(
        item.storagePath.path,
        controller.value.position,
      );
    }
    controller.dispose();
  }

  void _onPageChanged(int index) {
    _openToken++;
    setState(() {
      _releaseController();
      _currentIndex = index;
      _isZoomed = false;
    });
    final item = widget.items[index];
    if (item.isVideo) unawaited(_openVideo(item));
  }

  // -------------------------------------------------------------------- chrome

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDuration, _hideChrome);
  }

  /// Both go through `setState`: `_chromeVisible` drives the [IgnorePointer]
  /// around the controls, and a stale one leaves invisible buttons as hit
  /// targets — `IconButton` is `HitTestBehavior.opaque`, so the play button
  /// would swallow the swipe that should be turning the page.
  void _hideChrome() {
    if (!mounted) return;
    setState(() => _chromeVisible = false);
    _chromeAnimController.reverse();
  }

  void _showChrome() {
    setState(() => _chromeVisible = true);
    _chromeAnimController.forward();
    _scheduleHide();
  }

  /// Freezes paging (and the auto-hide) for as long as a finger is down on the
  /// seek bar.
  void _holdForScrub(bool holding) {
    setState(() => _scrubbing = holding);
    if (holding) {
      _hideTimer?.cancel();
    } else {
      _scheduleHide();
    }
  }

  void _toggleChrome() {
    if (_chromeVisible) {
      _hideTimer?.cancel();
      _hideChrome();
    } else {
      _showChrome();
    }
  }

  // ------------------------------------------------------------------ playback

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _scheduleHide();
  }

  void _skip(Duration delta) {
    final controller = _controller;
    if (controller == null) return;
    controller.seekTo(
      seekBy(controller.value.position, delta, controller.value.duration),
    );
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    _controller?.setPlaybackSpeed(speed);
    _scheduleHide();
  }

  void _toggleOrientation() {
    setState(() => _landscape = !_landscape);
    SystemChrome.setPreferredOrientations(
      _landscape
          ? const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
          : DeviceOrientation.values,
    );
    _scheduleHide();
  }

  // --------------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _chromeAnimController,
          child: AppBar(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // The counter shows even at 1/1: "why doesn't it swipe" is almost
            // always "nothing else in this folder is unlocked", and this is
            // where you see it.
            title: Text(
              '${_current.name}  ·  ${_currentIndex + 1}/${widget.items.length}',
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (_current.isVideo) ...[
                PopupMenuButton<double>(
                  tooltip: 'Playback speed',
                  initialValue: _speed,
                  onSelected: _setSpeed,
                  itemBuilder:
                      (_) =>
                          _speeds
                              .map(
                                (speed) => PopupMenuItem<double>(
                                  value: speed,
                                  child: Text('${_speedLabel(speed)}x'),
                                ),
                              )
                              .toList(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${_speedLabel(_speed)}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Rotate',
                  icon: Icon(
                    _landscape
                        ? Icons.stay_current_portrait_rounded
                        : Icons.screen_rotation_rounded,
                    color: Colors.white,
                  ),
                  onPressed: _toggleOrientation,
                ),
              ],
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Translucent so taps land here while horizontal drags still reach
          // the PageView underneath.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            // With a controller up, `_TapZones` handles taps (it also needs the
            // left/right split); here that means images and videos still
            // initializing.
            onTap: controller == null ? _toggleChrome : null,
            child: PageView.builder(
              controller: _pageController,
              physics:
                  _scrubbing || _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
              itemCount: widget.items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (_, index) {
                final item = widget.items[index];
                return _MediaPage(
                  key: ValueKey(item.storagePath.path),
                  item: item,
                  // Only the current page has a controller; the others show
                  // their poster until they settle.
                  controller: index == _currentIndex ? _controller : null,
                  onZoomChanged: (zoomed) {
                    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
                  },
                );
              },
            ),
          ),
          if (controller != null) ...[
            Positioned.fill(
              child: _TapZones(
                onTap: _toggleChrome,
                onSkip: _skip,
                step: _skipStep,
              ),
            ),
            Positioned.fill(
              child: FadeTransition(
                opacity: _chromeAnimController,
                child: IgnorePointer(
                  ignoring: !_chromeVisible,
                  child: Stack(
                    children: [
                      Center(
                        child: _CenterControls(
                          controller: controller,
                          step: _skipStep,
                          onTogglePlayback: _togglePlayback,
                          onSkip: _skip,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        // `_SeekBar` owns the gesture and raises this from its
                        // own pointer-down listener — see the doc comment there
                        // for why pointer-level and not `onChangeStart`.
                        child: _SeekBar(
                          controller: controller,
                          onScrubbing: _holdForScrub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// `1x`, not `1.0x`.
  String _speedLabel(double speed) =>
      speed == speed.roundToDouble()
          ? speed.toInt().toString()
          : speed.toString();
}
