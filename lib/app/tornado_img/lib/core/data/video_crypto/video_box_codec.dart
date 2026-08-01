// Reads and writes the custom `uuid` box that carries a video's ciphertext.
//
// An encrypted video is a normal, playable MP4 — a short cosmetic clip —
// followed by one top-level `uuid` box holding the real file, encrypted. Players
// ignore boxes they do not know, so the file stays valid and playable while the
// actual content is unreadable without the password.
//
// Layout, with box framing big-endian per ISO/IEC 14496-12 and our own payload
// fields big-endian too:
//
//   size u32 (or 1, then largesize u64)   ← total box size
//   'uuid'
//   usertype 16B                          ← Constants.videoBoxUserType
//   magic u32 'TVE1' | version u8 | salt 16B | kcv 16B
//   originalSize u64 | extLen u8 | ext ASCII
//   ciphertext (originalSize bytes)

import 'dart:io';
import 'dart:typed_data';

import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/file_name_utils.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

/// Header of the ciphertext box.
class VideoBoxHeader {
  const VideoBoxHeader({
    required this.salt,
    required this.kcv,
    required this.originalSize,
    required this.originalExt,
  });

  /// Per-video random salt. Exactly [saltLength] bytes.
  ///
  /// This is what stops two videos encrypted with the same password from
  /// sharing a keystream.
  final Uint8List salt;

  /// Encrypted key check value: the magic block ciphered at stream offset 0.
  ///
  /// Lets a wrong password be reported from 16 bytes instead of after
  /// decrypting the whole file. Exactly [kcvLength] bytes.
  final Uint8List kcv;

  /// Size of the original video in bytes. CTR preserves length, so this is also
  /// the ciphertext length.
  final int originalSize;

  /// Original extension without the dot, e.g. `mp4`.
  final String originalExt;

  static const int saltLength = 16;
  static const int kcvLength = 16;
}

/// A located ciphertext box inside an encrypted video file.
class ParsedVideoBox {
  const ParsedVideoBox({required this.header, required this.ciphertextOffset});

  final VideoBoxHeader header;

  /// Absolute file offset of the first ciphertext byte.
  final int ciphertextOffset;
}

const int _boxTypeUuid = 0x75756964; // 'uuid'
const int _fixedPayloadLength =
    4 + 1 + VideoBoxHeader.saltLength + VideoBoxHeader.kcvLength + 8 + 1;

/// Builds everything that precedes the ciphertext: box framing plus payload
/// header. The caller appends exactly `header.originalSize` ciphertext bytes.
Uint8List buildVideoBoxPrefix(VideoBoxHeader header) {
  if (header.salt.length != VideoBoxHeader.saltLength) {
    throw ArgumentError.value(
      header.salt,
      'salt',
      'must be exactly ${VideoBoxHeader.saltLength} bytes',
    );
  }
  if (header.kcv.length != VideoBoxHeader.kcvLength) {
    throw ArgumentError.value(
      header.kcv,
      'kcv',
      'must be exactly ${VideoBoxHeader.kcvLength} bytes',
    );
  }
  if (header.originalSize < 0) {
    throw ArgumentError.value(
      header.originalSize,
      'originalSize',
      'must not be negative',
    );
  }

  final ext = Uint8List.fromList(header.originalExt.codeUnits);
  if (ext.isEmpty || ext.length > 255) {
    throw ArgumentError.value(
      header.originalExt,
      'originalExt',
      'must be 1..255 ASCII characters',
    );
  }
  if (ext.any((c) => c > 0x7F)) {
    throw ArgumentError.value(
      header.originalExt,
      'originalExt',
      'must be ASCII',
    );
  }

  final payloadLength = _fixedPayloadLength + ext.length;
  // Try the compact 32-bit framing first; fall back to largesize when the whole
  // box cannot be described in a u32.
  final compactTotal = 8 + 16 + payloadLength + header.originalSize;
  final useLargeSize = compactTotal > 0xFFFFFFFF;
  final prefixLength = (useLargeSize ? 16 : 8) + 16 + payloadLength;
  final total = prefixLength + header.originalSize;

  final out = Uint8List(prefixLength);
  final view = ByteData.sublistView(out);
  var o = 0;

  if (useLargeSize) {
    view.setUint32(o, 1); // size == 1 signals a 64-bit largesize
    o += 4;
    view.setUint32(o, _boxTypeUuid);
    o += 4;
    view.setUint64(o, total);
    o += 8;
  } else {
    view.setUint32(o, total);
    o += 4;
    view.setUint32(o, _boxTypeUuid);
    o += 4;
  }

  out.setAll(o, Constants.videoBoxUserType);
  o += 16;

  view.setUint32(o, Constants.videoBoxMagic);
  o += 4;
  view.setUint8(o, Constants.videoBoxVersion);
  o += 1;
  out.setAll(o, header.salt);
  o += VideoBoxHeader.saltLength;
  out.setAll(o, header.kcv);
  o += VideoBoxHeader.kcvLength;
  view.setUint64(o, header.originalSize);
  o += 8;
  view.setUint8(o, ext.length);
  o += 1;
  out.setAll(o, ext);

  return out;
}

/// Builds a complete `uuid` box carrying the scrambled poster [png].
///
/// Written between the cosmetic clip and the ciphertext box so a folder scan
/// can show a thumbnail after reading a few hundred KB instead of the whole
/// file. Players ignore it exactly as they ignore the ciphertext box.
Uint8List buildPosterBox(Uint8List png) {
  if (png.isEmpty || png.length > Constants.maxPosterBytes) {
    throw ArgumentError.value(
      png.length,
      'png',
      'must be 1..${Constants.maxPosterBytes} bytes',
    );
  }

  final out = Uint8List(8 + 16 + png.length);
  final view = ByteData.sublistView(out);
  view.setUint32(0, out.length);
  view.setUint32(4, _boxTypeUuid);
  out.setAll(8, Constants.videoPosterUserType);
  out.setAll(24, png);
  return out;
}

/// Walks the top-level boxes of [raf] looking for our ciphertext box.
///
/// Returns null when the file has no such box or the payload is malformed —
/// both simply mean "this is not an encrypted video", not an error.
Future<ParsedVideoBox?> findVideoBox(RandomAccessFile raf) =>
    _walkUuidBoxes(raf, (bodyOffset, boxEnd) =>
        _readPayload(raf, bodyOffset, boxEnd));

/// Returns the scrambled poster PNG embedded by [buildPosterBox], or null when
/// the file carries none (older files, or not an encrypted video at all).
Future<Uint8List?> findPosterBox(RandomAccessFile raf) =>
    _walkUuidBoxes(raf, (bodyOffset, boxEnd) =>
        _readPoster(raf, bodyOffset, boxEnd));

/// Bytes a folder scan should carry as an encrypted media file's preview.
///
/// Images are their own preview, so the file is read whole. Videos are not:
/// the file is mostly ciphertext and may be gigabytes, so only the embedded
/// poster box is read. A video without one is not ours (or is corrupt) and
/// yields null so the caller can skip it instead of loading it into memory.
Future<Uint8List?> readMediaPreviewBytes(File file) async {
  if (!Constants.videoExtensions.contains(
    FileNameUtils.extensionOf(file.path),
  )) {
    return file.readAsBytes();
  }

  final raf = await file.open();
  try {
    final poster = await findPosterBox(raf);
    if (poster == null) {
      appLogger.log(
        'readMediaPreviewBytes: no poster box in ${file.path} — skipped',
        LogLayer.repository,
      );
    }
    return poster;
  } finally {
    await raf.close();
  }
}

/// Walks top-level boxes, handing every `uuid` box body to [onUuidBox]. The
/// first non-null result wins; a null one means "not the box we want, keep
/// walking", which is what lets the poster and ciphertext boxes coexist.
Future<T?> _walkUuidBoxes<T>(
  RandomAccessFile raf,
  Future<T?> Function(int bodyOffset, int boxEnd) onUuidBox,
) async {
  final fileLength = await raf.length();
  var offset = 0;

  while (offset + 8 <= fileLength) {
    await raf.setPosition(offset);
    final head = await raf.read(8);
    if (head.length < 8) return null;

    final headView = ByteData.sublistView(head);
    var size = headView.getUint32(0);
    final type = headView.getUint32(4);
    var bodyOffset = offset + 8;

    if (size == 1) {
      // 64-bit largesize follows the type.
      if (bodyOffset + 8 > fileLength) return null;
      final large = await raf.read(8);
      if (large.length < 8) return null;
      size = ByteData.sublistView(large).getUint64(0);
      bodyOffset += 8;
    } else if (size == 0) {
      // Box extends to end of file.
      size = fileLength - offset;
    }

    // A size that does not advance would spin forever on a corrupt file.
    if (size < bodyOffset - offset || offset + size > fileLength) return null;

    if (type == _boxTypeUuid) {
      final parsed = await onUuidBox(bodyOffset, offset + size);
      if (parsed != null) return parsed;
    }

    offset += size;
  }

  return null;
}

Future<Uint8List?> _readPoster(
  RandomAccessFile raf,
  int bodyOffset,
  int boxEnd,
) async {
  final length = boxEnd - bodyOffset - 16;
  if (length <= 0 || length > Constants.maxPosterBytes) return null;

  await raf.setPosition(bodyOffset);
  final userType = await raf.read(16);
  if (userType.length < 16) return null;
  for (var i = 0; i < 16; i++) {
    if (userType[i] != Constants.videoPosterUserType[i]) return null;
  }

  final png = await raf.read(length);
  return png.length < length ? null : png;
}

Future<ParsedVideoBox?> _readPayload(
  RandomAccessFile raf,
  int bodyOffset,
  int boxEnd,
) async {
  if (bodyOffset + 16 + _fixedPayloadLength > boxEnd) return null;

  await raf.setPosition(bodyOffset);
  final userType = await raf.read(16);
  for (var i = 0; i < 16; i++) {
    if (userType[i] != Constants.videoBoxUserType[i]) return null;
  }

  final fixed = await raf.read(_fixedPayloadLength);
  if (fixed.length < _fixedPayloadLength) return null;

  final view = ByteData.sublistView(fixed);
  var o = 0;

  if (view.getUint32(o) != Constants.videoBoxMagic) {
    appLogger.log('findVideoBox: bad payload magic', LogLayer.repository);
    return null;
  }
  o += 4;
  final version = view.getUint8(o);
  o += 1;
  if (version != Constants.videoBoxVersion) {
    appLogger.log(
      'findVideoBox: unsupported box version $version',
      LogLayer.repository,
    );
    return null;
  }

  final salt = Uint8List.fromList(
    fixed.sublist(o, o + VideoBoxHeader.saltLength),
  );
  o += VideoBoxHeader.saltLength;
  final kcv = Uint8List.fromList(
    fixed.sublist(o, o + VideoBoxHeader.kcvLength),
  );
  o += VideoBoxHeader.kcvLength;
  final originalSize = view.getUint64(o);
  o += 8;
  final extLen = view.getUint8(o);
  if (extLen == 0) {
    appLogger.log('findVideoBox: extLen is zero', LogLayer.repository);
    return null;
  }

  final extBytes = await raf.read(extLen);
  if (extBytes.length < extLen) return null;
  final ext = String.fromCharCodes(extBytes);

  final ciphertextOffset = bodyOffset + 16 + _fixedPayloadLength + extLen;
  // The declared payload must actually fit inside the box we just framed.
  if (ciphertextOffset + originalSize > boxEnd) {
    appLogger.log(
      'findVideoBox: declared size $originalSize overflows the box',
      LogLayer.repository,
    );
    return null;
  }

  return ParsedVideoBox(
    header: VideoBoxHeader(
      salt: salt,
      kcv: kcv,
      originalSize: originalSize,
      originalExt: ext,
    ),
    ciphertextOffset: ciphertextOffset,
  );
}
