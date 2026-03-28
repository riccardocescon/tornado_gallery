import 'dart:typed_data';

class ImageLruCache {
  ImageLruCache({this.maxSize = 30});

  final int maxSize;
  final _cache = <String, Uint8List>{};

  Uint8List? get(String path) {
    final value = _cache.remove(path);
    if (value != null) _cache[path] = value; // move to end (most recent)
    return value;
  }

  void put(String path, Uint8List bytes) {
    _cache.remove(path); // remove to re-insert at end
    _cache[path] = bytes;
    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first); // evict LRU (head)
    }
  }

  void clear() => _cache.clear();
}
