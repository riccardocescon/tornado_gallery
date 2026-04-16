import 'dart:async';

class StreamManager<T> {
  late StreamController<T> _controller;
  StreamSubscription<T>? _subscription;

  Stream<T> get stream => _controller.stream;

  StreamManager();
  StreamManager.fromStream(Stream<T> stream) {
    addStream(stream);
  }

  void addStream(Stream<T> stream) {
    _controller = StreamController<T>();
    _subscription = stream.listen(
      (data) {
        _controller.add(data);
      },
      onError: (Object error, StackTrace stackTrace) {
        _controller.addError(error, stackTrace);
      },
    );
  }

  Future<void> dispose() async {
    if (_subscription == null) return;

    final sub = _subscription;
    _subscription = null;
    await _controller.close();
    
    // Native stream cancel can hang
    sub!.cancel();
  }
}
