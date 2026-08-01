// Thin wrapper over tornado_img_crypto's native video streaming API.
//
// The package does the actual chunked AES-256-CTR streaming
// (`processVideoFile`) and the single-block cipher used for the key check
// value (`processVideoBlock`) — see its own `video_crypto_test.dart` for
// coverage of the cipher itself. This wrapper exists only to pin down the two
// conventions every caller must get right and must get right identically:
// which 16 bytes are the KCV plaintext, and which stream offset the payload
// starts at (block 0 is reserved for the KCV — see [videoStreamDataOffset]).

import 'dart:typed_data';

import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

/// Computes the key check value: [Constants.videoBoxUserType] encrypted at
/// stream offset 0 under [phrase]/[salt].
///
/// Recomputing this and comparing against the stored kcv detects a wrong
/// password from 16 bytes instead of after decrypting a multi-GB file.
/// Synchronous — 16 bytes is not worth an isolate hop.
///
/// ponytail: this is a wrong-password *detector*, not an integrity guarantee
/// — there is no MAC, so a tampered ciphertext still decrypts to garbage
/// undetected. Upgrade path if that's ever needed: authenticated encryption
/// (e.g. AES-GCM, or an HMAC over the ciphertext).
Uint8List videoKeyCheckValue(String phrase, Uint8List salt) => processVideoBlock(
  block: Uint8List.fromList(Constants.videoBoxUserType),
  phrase: phrase,
  salt: salt,
);

/// True if recomputing the kcv for [phrase]/[salt] matches the stored [kcv].
bool matchesVideoKeyCheckValue(String phrase, Uint8List salt, Uint8List kcv) =>
    _bytesEqual(videoKeyCheckValue(phrase, salt), kcv);

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Encrypts or decrypts [length] payload bytes from [srcPath] into
/// [dstPath], starting the CTR stream at [videoStreamDataOffset] — block 0 is
/// reserved for the key check value, so payload must never start there.
///
/// Symmetric: the same call with the same [phrase] and [salt] reverses
/// itself. Returns the [VideoProcessHandle] unchanged, so callers get
/// `progress` and `cancel()` for free.
VideoProcessHandle processVideoPayload({
  required String srcPath,
  required int srcOffset,
  required int length,
  required String dstPath,
  required String phrase,
  required Uint8List salt,
  bool append = false,
}) => processVideoFile(
  srcPath: srcPath,
  srcOffset: srcOffset,
  length: length,
  dstPath: dstPath,
  phrase: phrase,
  salt: salt,
  append: append,
  streamOffset: videoStreamDataOffset,
);
