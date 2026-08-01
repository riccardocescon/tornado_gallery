import 'dart:io';

import 'package:tornado_img_app/core/utils/globals.dart';

/// Keeps a decrypted video alive across navigation — the file-level counterpart
/// of `EncryptedImage.decryptInfo` in [AppBloc].
///
/// Images cache their plaintext as bytes in the canonical [AppBloc] store; a
/// video's plaintext is up to 2 GB, so what is cached here is the path of the
/// temp file `DecryptVideoUseCase` wrote, plus the last playback position. Leave
/// the player page and come back: it re-attaches to the same file at the same
/// second, no password.
///
/// App-lifetime singleton (see `injection_container.dart`). Entries die on
/// Restore, on folder re-encrypt, or at the next session's [sweepOnce].
///
/// ponytail: no size cap / LRU — scrubbing through enough 2 GB videos in one
/// session to fill the temp dir isn't a real flow. Add eviction by total bytes
/// if it ever is.
class DecryptedVideoCache {
  final Map<String, _Entry> _entries = <String, _Entry>{};
  Future<void>? _sweep;

  /// Temp dir [DecryptVideoUseCase] writes plaintext into.
  static Directory get tempDir =>
      Directory('${Directory.systemTemp.path}/tornado_video');

  /// The cached plaintext for [encryptedPath], or null on a miss. Auto-evicts
  /// when the file vanished under us (OS temp cleanup) so callers never hand a
  /// dead path to `VideoPlayerController.file`.
  ({File file, Duration position})? entry(String encryptedPath) {
    final cached = _entries[encryptedPath];
    if (cached == null) return null;
    if (!cached.file.existsSync()) {
      _entries.remove(encryptedPath);
      appLogger.log(
        'DecryptedVideoCache: temp file vanished, evicted',
        LogLayer.core,
        error: cached.file.path,
      );
      return null;
    }
    return (file: cached.file, position: cached.position);
  }

  void put(String encryptedPath, File file) {
    _entries[encryptedPath] = _Entry(file);
  }

  void savePosition(String encryptedPath, Duration position) {
    _entries[encryptedPath]?.position = position;
  }

  /// Follows a rename: the cache is keyed by the *encrypted* file's path.
  void rekey(String oldPath, String newPath) {
    final cached = _entries.remove(oldPath);
    if (cached != null) _entries[newPath] = cached;
  }

  /// Drops the entry and deletes the plaintext. No-op on a miss.
  Future<void> evict(String encryptedPath) async {
    final cached = _entries.remove(encryptedPath);
    if (cached == null) return;
    if (await cached.file.exists()) await cached.file.delete();
  }

  /// Clears plaintext a previous run left behind. Runs **once per session**,
  /// before the first decrypt: after that the same directory holds the live
  /// cache entries, and a second sweep would delete them.
  ///
  /// Memoized as a future, not a bool: concurrent callers (the bulk decrypt job
  /// runs several videos at once) must all wait for the same delete to finish,
  /// or a later one starts writing into a directory still being wiped.
  Future<void> sweepOnce() => _sweep ??= _sweep0();

  Future<void> _sweep0() async {
    final dir = tempDir;
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  /// Drops every entry and its plaintext.
  Future<void> clear() async {
    final files = _entries.values.map((e) => e.file).toList();
    _entries.clear();
    for (final file in files) {
      if (await file.exists()) await file.delete();
    }
  }
}

class _Entry {
  _Entry(this.file);

  final File file;
  Duration position = Duration.zero;
}
