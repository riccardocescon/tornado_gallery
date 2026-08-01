import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen playback for an already-decrypted video, mirroring
/// [FullscreenImageViewer]: black background, auto-hiding chrome, tap to bring
/// it back.
///
/// Takes the caller's initialised [VideoPlayerController] and renders a second
/// [VideoPlayer] on the same texture — no second decrypt, no second temp file.
/// Disposal stays with the caller.
class FullscreenVideoViewer extends StatefulWidget {
  const FullscreenVideoViewer({
    super.key,
    required this.controller,
    this.title,
  });

  final VideoPlayerController controller;
  final String? title;

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _chromeAnimController;
  bool _chromeVisible = true;
  Timer? _hideTimer;

  static const _hideDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _chromeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _scheduleHide();
    widget.controller.addListener(_onPlaybackChanged);
  }

  void _onPlaybackChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDuration, _hideChrome);
  }

  void _hideChrome() {
    if (!mounted) return;
    _chromeVisible = false;
    _chromeAnimController.reverse();
  }

  void _onTap() {
    if (_chromeVisible) {
      _hideTimer?.cancel();
      _hideChrome();
    } else {
      _chromeVisible = true;
      _chromeAnimController.forward();
      _scheduleHide();
    }
  }

  void _togglePlayback() {
    final controller = widget.controller;
    controller.value.isPlaying ? controller.pause() : controller.play();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _chromeAnimController.dispose();
    // The controller belongs to the page that pushed this viewer.
    widget.controller.removeListener(_onPlaybackChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

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
              onPressed: () => context.pop(),
            ),
            title: widget.title == null ? null : Text(widget.title!),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        onDoubleTap: _togglePlayback,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            FadeTransition(
              opacity: _chromeAnimController,
              child: IconButton(
                iconSize: 64,
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                ),
                onPressed: _togglePlayback,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _chromeAnimController,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
