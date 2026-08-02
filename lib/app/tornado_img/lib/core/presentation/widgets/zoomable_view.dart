import 'package:flutter/material.dart';

/// Pinch/double-tap zoom around any [child], shared by the fullscreen image
/// viewer and the fullscreen media pager (images *and* video).
///
/// [onZoomChanged] lets the host `PageView` swap to
/// [NeverScrollableScrollPhysics] while zoomed, so a pan doesn't turn a page.
/// Panning only switches on once zoomed — at rest there is nothing to pan, and
/// leaving it off keeps the horizontal drag with the pager.
class ZoomableView extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onZoomChanged;

  /// Off for video: there the double tap is ±10s, and both can't own the same
  /// gesture.
  final bool doubleTapToZoom;

  const ZoomableView({
    super.key,
    required this.child,
    required this.onZoomChanged,
    this.doubleTapToZoom = true,
  });

  @override
  State<ZoomableView> createState() => _ZoomableViewState();
}

class _ZoomableViewState extends State<ZoomableView>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _animation;
  bool _zoomed = false;

  static const double _zoomedScale = 2.5;

  /// Scale above which the child counts as "zoomed" (small epsilon over 1.0
  /// to ignore floating-point noise at the resting scale).
  static const double _zoomedThreshold = 1.01;
  static const double _minScale = 0.5;
  static const double _maxScale = 4.0;

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
    final zoomed = _controller.value.getMaxScaleOnAxis() > _zoomedThreshold;
    widget.onZoomChanged(zoomed);
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final Matrix4 target;
    if (_controller.value.getMaxScaleOnAxis() > _zoomedThreshold) {
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
    final viewer = InteractiveViewer(
      transformationController: _controller,
      minScale: _minScale,
      maxScale: _maxScale,
      panEnabled: _zoomed,
      child: Center(child: widget.child),
    );

    if (!widget.doubleTapToZoom) return viewer;

    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      child: viewer,
    );
  }
}
