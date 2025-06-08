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
    _subscription = stream.listen((data) {
      _controller.add(data);
    });
  }

  Future<void> dispose() async {
    if (_subscription == null) return;

    await _subscription!.cancel();
    await _controller.close();
  }
}
