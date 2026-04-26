part of '../encrypted_image_page.dart';

class _FullscreenImageViewer extends StatefulWidget {
  final List<EncryptedImage> images;
  final int initialIndex;

  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer>
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
            title: Text('${_currentIndex + 1} / ${widget.images.length}'),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isZoomed,
          builder: (context, isZoomed, _) {
            return PageView.builder(
              controller: _pageController,
              physics:
                  isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const PageScrollPhysics(),
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _isZoomed.value = false;
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];
                final bytes =
                    image.decryptInfo?.bytes ?? image.encryptedInfo.bytes;
                return _ZoomablePage(
                  key: ValueKey(image.path),
                  bytes: bytes,
                  onZoomChanged: (zoomed) => _isZoomed.value = zoomed,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ZoomablePage extends StatefulWidget {
  final Uint8List bytes;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomablePage({
    super.key,
    required this.bytes,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  static const double _zoomedScale = 2.5;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
      if (_animation != null) {
        _controller.value = _animation!.value;
      }
    });
  }

  void _onTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.01);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final isZoomed = _controller.value.getMaxScaleOnAxis() > 1.01;

    final Matrix4 target;
    if (isZoomed) {
      target = Matrix4.identity();
    } else {
      final position = details.localPosition;
      target =
          Matrix4.identity()
            ..translateByDouble(
              -position.dx * (_zoomedScale - 1),
              -position.dy * (_zoomedScale - 1),
              0.0,
              1.0,
            )
            ..scaleByDouble(_zoomedScale, _zoomedScale, 1.0, 1.0);
    }

    _animation = Matrix4Tween(begin: _controller.value, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(child: Image.memory(widget.bytes, fit: BoxFit.contain)),
      ),
    );
  }
}
