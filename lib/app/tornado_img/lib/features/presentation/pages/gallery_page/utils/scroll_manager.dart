part of '../gallery_page.dart';

/// Manages all scroll logic for the gallery
class GalleryScrollManager {
  static const int _visibleItemsBuffer = 6;
  static const double _itemHeight =
      4 + 8 / 3; // spacing + height / crossAxisCount
  static const double _loadMoreThreshold = 0.9;
  static const Duration _savePositionDelay = Duration(milliseconds: 500);
  static const Duration _restorePositionDelay = Duration(milliseconds: 200);

  final ScrollController _controller;
  final VoidCallback onLoadMore;
  final Function(double) onPositionSaved;

  final ValueNotifier<(int, int)> _visibleRange = ValueNotifier((0, 20));
  Timer? _savePositionTimer;
  bool _isLoadingMore = false;

  GalleryScrollManager({
    required this.onLoadMore,
    required this.onPositionSaved,
  }) : _controller = ScrollController() {
    _controller.addListener(_onScroll);
  }

  ScrollController get controller => _controller;
  ValueNotifier<(int, int)> get visibleRange => _visibleRange;
  bool get isLoadingMore => _isLoadingMore;

  void _onScroll() {
    if (_isLoadingMore) return;

    _scheduleSavePosition();
    _updateVisibleRange();
    _checkLoadMore();
  }

  void _scheduleSavePosition() {
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(_savePositionDelay, _saveCurrentPosition);
  }

  void _saveCurrentPosition() {
    if (!_controller.hasClients) return;

    final position = _controller.position.pixels;
    onPositionSaved(position);
    log('💾 Scroll position saved: $position');
  }

  void _updateVisibleRange() {
    if (!_controller.hasClients) return;

    final scrollTop = _controller.position.pixels;
    final viewHeight = _controller.position.viewportDimension;

    final startIndex =
        (scrollTop / _itemHeight * 3).floor().clamp(0, double.infinity).toInt();

    final endIndex =
        ((scrollTop + viewHeight) / _itemHeight * 3)
            .ceil()
            .clamp(0, double.infinity)
            .toInt();

    _visibleRange.value = (startIndex, endIndex + _visibleItemsBuffer);
  }

  void _checkLoadMore() {
    if (!_controller.hasClients) return;

    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent * _loadMoreThreshold) {
      _isLoadingMore = true;
      onLoadMore();
    }
  }

  void setLoadingCompleted() {
    _isLoadingMore = false;
  }

  Future<void> restorePosition(double? savedPosition) async {
    if (savedPosition == null || !_controller.hasClients) return;

    await _waitForContent();

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll == 0.0) {
      // Retry if content is not loaded yet
      await Future.delayed(_restorePositionDelay);
      await restorePosition(savedPosition);
      return;
    }

    final targetPosition = savedPosition.clamp(0.0, maxScroll);
    log(
      '🔄 Restoring scroll: saved=$savedPosition, max=$maxScroll, target=$targetPosition',
    );

    _controller.jumpTo(targetPosition);
  }

  Future<void> _waitForContent() async {
    await Future.delayed(_restorePositionDelay);
  }

  void dispose() {
    _savePositionTimer?.cancel();
    _controller.dispose();
    _visibleRange.dispose();
  }
}
