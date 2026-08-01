// Streams a file through the native AES-256-CTR engine in fixed-size chunks.
//
// Chunking exists because the native engine's Fisher-Yates keystream
// permutation allocates a table proportional to input size (~32 MB per 4 MiB
// chunk) — processing a whole video in one call would scale that allocation
// with file size. Each chunk gets its own phrase (salt + chunk index mixed
// in), which is what keeps the keystream from repeating across videos and
// across chunks of the same video; getting that mixing wrong is a
// cryptographic break, not a style issue.

import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart' as native;

/// Encrypts or decrypts one chunk under [phrase]. Symmetric: the same call
/// reverses itself.
typedef ChunkProcessor = Future<Uint8List> Function(Uint8List input, String phrase);

Future<Uint8List> _defaultProcessor(Uint8List input, String phrase) =>
    native.processImage(input: input, phrase: phrase, useRgb: false);

/// Chunked, salt-mixed AES-256-CTR streaming over the native engine.
///
/// [process] is symmetric — the same call encrypts and decrypts — because the
/// underlying [ChunkProcessor] is symmetric per chunk.
class VideoCipher {
  /// [processor] defaults to the real `processImage`. Injectable so unit
  /// tests can exercise the chunking/streaming logic without the native DLL.
  VideoCipher({ChunkProcessor? processor})
    : _processor = processor ?? _defaultProcessor;

  final ChunkProcessor _processor;

  /// Lowercase, zero-padded, separator-free hex of [bytes]. Deterministic —
  /// this exact shape is load-bearing for [chunkPhrase] and the kcv phrase.
  static String hex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Shared phrase shape for both real chunks and the kcv, so the two can
  /// never drift apart: `'$phrase ${hex(salt)} $suffix'`.
  static String _saltedPhrase(String phrase, Uint8List salt, String suffix) =>
      '$phrase ${hex(salt)} $suffix';

  /// Per-chunk phrase: mixes in [salt] (kills cross-video keystream reuse)
  /// and [chunkIndex] (kills cross-chunk keystream reuse).
  static String chunkPhrase(String phrase, Uint8List salt, int chunkIndex) =>
      _saltedPhrase(phrase, salt, '$chunkIndex');

  /// Fixed 16-byte plaintext for the key check value.
  /// Recomputing this and comparing against the stored kcv detects a wrong
  /// password from 16 bytes instead of after decrypting a multi-GB file.
  ///
  /// The phrase suffix is the literal `kcv`, never a decimal integer, so the
  /// kcv keystream can never coincide with a real chunk's.
  ///
  /// ponytail: this is a wrong-password *detector*, not an integrity
  /// guarantee — there is no MAC, so a tampered ciphertext still decrypts to
  /// garbage undetected. Upgrade path if that's ever needed: authenticated
  /// encryption (e.g. AES-GCM, or an HMAC over the ciphertext).
  static Future<Uint8List> keyCheckValue(
    String phrase,
    Uint8List salt, {
    ChunkProcessor? processor,
  }) {
    final process = processor ?? _defaultProcessor;
    return process(
      Uint8List.fromList(Constants.videoBoxUserType),
      _saltedPhrase(phrase, salt, 'kcv'),
    );
  }

  /// True if recomputing the kcv for [phrase] and [salt] matches [kcv].
  static Future<bool> matchesKeyCheckValue(
    String phrase,
    Uint8List salt,
    Uint8List kcv, {
    ChunkProcessor? processor,
  }) async {
    final computed = await keyCheckValue(phrase, salt, processor: processor);
    if (computed.length != kcv.length) return false;
    for (var i = 0; i < computed.length; i++) {
      if (computed[i] != kcv[i]) return false;
    }
    return true;
  }

  /// Reads [totalBytes] from [src] (already positioned) in [chunkSize]
  /// pieces, processes each chunk through the [ChunkProcessor], and writes
  /// the results to [out] in order. Symmetric: the same call decrypts.
  Future<void> process({
    required RandomAccessFile src,
    required IOSink out,
    required int totalBytes,
    required String phrase,
    required Uint8List salt,
    required int chunkSize,
  }) async {
    if (chunkSize <= 0) {
      throw ArgumentError.value(chunkSize, 'chunkSize', 'must be > 0');
    }
    if (totalBytes < 0) {
      throw ArgumentError.value(
        totalBytes,
        'totalBytes',
        'must not be negative',
      );
    }

    var remaining = totalBytes;
    var chunkIndex = 0;
    while (remaining > 0) {
      final want = remaining < chunkSize ? remaining : chunkSize;
      final chunk = await src.read(want);
      if (chunk.length != want) {
        throw StateError(
          'VideoCipher.process: expected $want bytes for chunk $chunkIndex, '
          'got ${chunk.length} (source truncated).',
        );
      }

      final processed = await _processor(
        chunk,
        chunkPhrase(phrase, salt, chunkIndex),
      );
      out.add(processed);
      // Bound how much unwritten data can queue up in memory when out drains
      // slower than we produce chunks.
      await out.flush();

      remaining -= chunk.length;
      chunkIndex++;
    }
  }
}
