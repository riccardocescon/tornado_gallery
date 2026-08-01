import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('video_box_codec_test');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Uint8List bytes(int n, [int seed = 0]) =>
      Uint8List.fromList(List.generate(n, (i) => (i + seed) & 0xFF));

  /// A minimal but structurally valid mp4: an `ftyp` box then an `mdat` box.
  Uint8List fakeMp4() {
    final out = BytesBuilder();

    void box(String type, List<int> body) {
      final head = ByteData(8);
      head.setUint32(0, 8 + body.length);
      for (var i = 0; i < 4; i++) {
        head.setUint8(4 + i, type.codeUnitAt(i));
      }
      out.add(head.buffer.asUint8List());
      out.add(body);
    }

    box('ftyp', 'isom'.codeUnits + [0, 0, 0, 0]);
    box('mdat', List.filled(32, 0xAB));
    return out.toBytes();
  }

  VideoBoxHeader header({int size = 128, String ext = 'mp4'}) => VideoBoxHeader(
    salt: bytes(VideoBoxHeader.saltLength, 3),
    kcv: bytes(VideoBoxHeader.kcvLength, 9),
    originalSize: size,
    originalExt: ext,
  );

  Future<File> writeFile(String name, List<int> content) async {
    final f = File('${tmp.path}/$name');
    await f.writeAsBytes(content);
    return f;
  }

  Future<T> withRaf<T>(File f, Future<T> Function(RandomAccessFile) body) async {
    final raf = await f.open();
    try {
      return await body(raf);
    } finally {
      await raf.close();
    }
  }

  group('buildVideoBoxPrefix / findVideoBox', () {
    test('roundtrips a box appended to a valid mp4', () async {
      final ciphertext = bytes(128, 77);
      final h = header(size: ciphertext.length);
      final prefix = buildVideoBoxPrefix(h);
      final cosmetic = fakeMp4();

      final f = await writeFile('enc.mp4', [
        ...cosmetic,
        ...prefix,
        ...ciphertext,
      ]);

      final parsed = await withRaf(f, findVideoBox);

      expect(parsed, isNotNull);
      expect(parsed!.ciphertextOffset, cosmetic.length + prefix.length);
      expect(parsed.header.originalSize, ciphertext.length);
      expect(parsed.header.originalExt, 'mp4');
      expect(parsed.header.salt, equals(h.salt));
      expect(parsed.header.kcv, equals(h.kcv));

      // The offset must actually point at the ciphertext.
      final actual = await withRaf(f, (raf) async {
        await raf.setPosition(parsed.ciphertextOffset);
        return raf.read(ciphertext.length);
      });
      expect(actual, equals(ciphertext));
    });

    test('preserves a .mov extension', () async {
      final h = header(size: 16, ext: 'mov');
      final f = await writeFile('enc.mp4', [
        ...fakeMp4(),
        ...buildVideoBoxPrefix(h),
        ...bytes(16),
      ]);

      final parsed = await withRaf(f, findVideoBox);
      expect(parsed!.header.originalExt, 'mov');
    });

    test('returns null for an mp4 without our box', () async {
      final f = await writeFile('plain.mp4', fakeMp4());
      expect(await withRaf(f, findVideoBox), isNull);
    });

    test('returns null for an empty file', () async {
      final f = await writeFile('empty.mp4', <int>[]);
      expect(await withRaf(f, findVideoBox), isNull);
    });

    test('returns null when the magic is corrupted', () async {
      final prefix = buildVideoBoxPrefix(header(size: 16));
      // The magic sits right after the 8-byte box head and 16-byte usertype.
      prefix[8 + 16] ^= 0xFF;

      final f = await writeFile('bad.mp4', [
        ...fakeMp4(),
        ...prefix,
        ...bytes(16),
      ]);
      expect(await withRaf(f, findVideoBox), isNull);
    });

    test('returns null when the declared size overflows the box', () async {
      // Claim far more ciphertext than the file actually carries.
      final prefix = buildVideoBoxPrefix(header(size: 16));
      final f = await writeFile('short.mp4', [
        ...fakeMp4(),
        ...prefix,
        ...bytes(4), // 4 bytes instead of the declared 16
      ]);
      expect(await withRaf(f, findVideoBox), isNull);
    });

    test('finds the box even when it is the only content', () async {
      final h = header(size: 32);
      final f = await writeFile('bare.mp4', [
        ...buildVideoBoxPrefix(h),
        ...bytes(32),
      ]);

      final parsed = await withRaf(f, findVideoBox);
      expect(parsed, isNotNull);
      expect(parsed!.header.originalSize, 32);
    });

    test('uses 64-bit largesize framing past 4 GiB', () {
      // Only the prefix bytes are inspected — no giant buffer is allocated.
      const huge = 0xFFFFFFFF;
      final prefix = buildVideoBoxPrefix(
        VideoBoxHeader(
          salt: bytes(VideoBoxHeader.saltLength),
          kcv: bytes(VideoBoxHeader.kcvLength),
          originalSize: huge,
          originalExt: 'mp4',
        ),
      );

      final view = ByteData.sublistView(prefix);
      expect(view.getUint32(0), 1, reason: 'size==1 signals largesize');
      expect(view.getUint32(4), 0x75756964, reason: "type is 'uuid'");
      expect(view.getUint64(8), prefix.length + huge);
    });

    test('uses compact 32-bit framing for normal sizes', () {
      final prefix = buildVideoBoxPrefix(header(size: 128));
      final view = ByteData.sublistView(prefix);
      expect(view.getUint32(0), prefix.length + 128);
      expect(view.getUint32(4), 0x75756964);
    });

    test('writes the agreed usertype', () {
      final prefix = buildVideoBoxPrefix(header(size: 16));
      expect(
        prefix.sublist(8, 24),
        equals(Uint8List.fromList(Constants.videoBoxUserType)),
      );
    });
  });

  group('buildPosterBox / findPosterBox', () {
    test('roundtrips a poster box sitting before the ciphertext box', () async {
      final png = bytes(512, 5);
      final ciphertext = bytes(64, 21);
      final h = header(size: ciphertext.length);
      final cosmetic = fakeMp4();
      final poster = buildPosterBox(png);
      final prefix = buildVideoBoxPrefix(h);

      final f = await writeFile('enc.mp4', [
        ...cosmetic,
        ...poster,
        ...prefix,
        ...ciphertext,
      ]);

      expect(await withRaf(f, findPosterBox), equals(png));

      // The poster box must not disturb the ciphertext box behind it.
      final parsed = await withRaf(f, findVideoBox);
      expect(
        parsed!.ciphertextOffset,
        cosmetic.length + poster.length + prefix.length,
      );
    });

    test('returns null when only the ciphertext box is present', () async {
      final f = await writeFile('enc.mp4', [
        ...fakeMp4(),
        ...buildVideoBoxPrefix(header(size: 16)),
        ...bytes(16),
      ]);
      expect(await withRaf(f, findPosterBox), isNull);
    });

    test('returns null for an mp4 without our boxes', () async {
      final f = await writeFile('plain.mp4', fakeMp4());
      expect(await withRaf(f, findPosterBox), isNull);
    });

    test('writes the agreed usertype', () {
      final box = buildPosterBox(bytes(16));
      expect(
        box.sublist(8, 24),
        equals(Uint8List.fromList(Constants.videoPosterUserType)),
      );
      expect(ByteData.sublistView(box).getUint32(0), box.length);
    });

    test('rejects an empty poster', () {
      expect(() => buildPosterBox(Uint8List(0)), throwsArgumentError);
    });

    test('rejects a poster larger than the read cap', () {
      expect(
        () => buildPosterBox(Uint8List(Constants.maxPosterBytes + 1)),
        throwsArgumentError,
      );
    });
  });

  group('buildVideoBoxPrefix validation', () {
    test('rejects a salt of the wrong length', () {
      expect(
        () => buildVideoBoxPrefix(
          VideoBoxHeader(
            salt: bytes(8),
            kcv: bytes(VideoBoxHeader.kcvLength),
            originalSize: 16,
            originalExt: 'mp4',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a kcv of the wrong length', () {
      expect(
        () => buildVideoBoxPrefix(
          VideoBoxHeader(
            salt: bytes(VideoBoxHeader.saltLength),
            kcv: bytes(4),
            originalSize: 16,
            originalExt: 'mp4',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty extension', () {
      expect(
        () => buildVideoBoxPrefix(header(size: 16, ext: '')),
        throwsArgumentError,
      );
    });
  });
}
