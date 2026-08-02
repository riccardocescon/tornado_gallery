import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/core/presentation/widgets/zoomable_view.dart';

class FullscreenImageViewer<T> extends StatefulWidget {
  final List<T> images;
  final Uint8List Function(T image) getBytes;
  final String Function(T image) getFilePath;
  final int initialIndex;
  final VoidCallback? onDismiss;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.getBytes,
    required this.getFilePath,
    required this.initialIndex,
    this.onDismiss,
  });

  @override
  State<FullscreenImageViewer<T>> createState() =>
      _FullscreenImageViewerState<T>();
}

class _FullscreenImageViewerState<T> extends State<FullscreenImageViewer<T>>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;
  final _isZoomed = ValueNotifier<bool>(false);

  late AnimationController _appBarAnimController;
  late Animation<double> _appBarOpacity;
  bool _appBarVisible = true;
  Timer? _hideTimer;

  static const _hideDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _appBarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _appBarOpacity = _appBarAnimController;
    _scheduleHide();
    _isZoomed.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDuration, _hideAppBar);
  }

  void _hideAppBar() {
    if (!mounted) return;
    _appBarVisible = false;
    _appBarAnimController.reverse();
  }

  void _showAppBar() {
    _appBarVisible = true;
    _appBarAnimController.forward();
  }

  void _onTap() {
    if (_appBarVisible) {
      _hideTimer?.cancel();
      _hideAppBar();
    } else {
      _showAppBar();
      _scheduleHide();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _appBarAnimController.dispose();
    _pageController.dispose();
    _isZoomed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _appBarOpacity,
          child: AppBar(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onDismiss ?? () => context.pop(),
            ),
            title: Text('${_currentIndex + 1} / ${widget.images.length}'),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child: PageView.builder(
          controller: _pageController,
          physics:
              _isZoomed.value
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            _isZoomed.value = false;
          },
          itemBuilder: (context, index) {
            final image = widget.images[index];
            final bytes = widget.getBytes(image);
            final filePath = widget.getFilePath(image);
            return ZoomableView(
              key: ValueKey(filePath),
              onZoomChanged: (zoomed) => _isZoomed.value = zoomed,
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
