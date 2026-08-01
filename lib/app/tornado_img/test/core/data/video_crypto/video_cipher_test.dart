@Tags(['native'])
library;

// These tests exercise our wrapper's own conventions — which 16 bytes are the
// KCV plaintext, and which stream offset the payload starts at — not the
// cipher itself. The cipher (processVideoFile/processVideoBlock) has its own
// coverage in tornado_img_crypto's video_crypto_test.dart. Requires the real
// native DLL, hence the tag and the existsSync guard below.

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

// The DLL lives at <repo root>/lib/cpp/build/tornado_crypto.dll. `flutter
// test` runs with the current directory set to this package
// (lib/app/tornado_img), so two levels up reaches the repo root.
const String _dllPath = '../../cpp/build/tornado_crypto.dll';

void main() {
  final dllPresent = File(_dllPath).existsSync();
  final skip = dllPresent ? false : 'native tornado_crypto.dll not found at $_dllPath';

  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('video_cipher_test');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Uint8List salt([int seed = 1]) =>
      Uint8List.fromList(List.generate(16, (i) => (i + seed) & 0xFF));

  group('videoKeyCheckValue', () {
    test('same phrase and salt give the same kcv', () {
      final s = salt();
      expect(videoKeyCheckValue('pw', s), equals(videoKeyCheckValue('pw', s)));
    }, skip: skip);

    test('a different phrase gives a different kcv', () {
      final s = salt();
      expect(
        videoKeyCheckValue('pw1', s),
        isNot(equals(videoKeyCheckValue('pw2', s))),
      );
    }, skip: skip);

    test('a different salt gives a different kcv', () {
      expect(
        videoKeyCheckValue('pw', salt(1)),
        isNot(equals(videoKeyCheckValue('pw', salt(2)))),
      );
    }, skip: skip);
  });

  group('matchesVideoKeyCheckValue', () {
    test('true for a matching password', () {
      final s = salt();
      final kcv = videoKeyCheckValue('pw', s);
      expect(matchesVideoKeyCheckValue('pw', s, kcv), isTrue);
    }, skip: skip);

    test('false for a wrong password', () {
      final s = salt();
      final kcv = videoKeyCheckValue('pw', s);
      expect(matchesVideoKeyCheckValue('wrong', s, kcv), isFalse);
    }, skip: skip);
  });

  group('processVideoPayload', () {
    test('roundtrips a non-block-aligned file, bit-perfect', () async {
      final rnd = Random(1234);
      final original = Uint8List.fromList(
        List.generate(1024 * 1024 + 7, (_) => rnd.nextInt(256)),
      );
      final src = File('${tmp.path}/src.bin');
      await src.writeAsBytes(original);
      final enc = File('${tmp.path}/enc.bin');
      final dec = File('${tmp.path}/dec.bin');
      final s = salt(3);

      await processVideoPayload(
        srcPath: src.path,
        srcOffset: 0,
        length: original.length,
        dstPath: enc.path,
        phrase: 'video-password',
        salt: s,
      ).done;

      final encrypted = await enc.readAsBytes();
      expect(encrypted.length, original.length);
      expect(encrypted, isNot(equals(original)));

      await processVideoPayload(
        srcPath: enc.path,
        srcOffset: 0,
        length: encrypted.length,
        dstPath: dec.path,
        phrase: 'video-password',
        salt: s,
      ).done;

      expect(await dec.readAsBytes(), equals(original));
    }, skip: skip);

    test('starts the payload stream at videoStreamDataOffset', () async {
      final original = Uint8List.fromList(List.generate(4096, (i) => i & 0xFF));
      final src = File('${tmp.path}/src.bin');
      await src.writeAsBytes(original);
      final s = salt(9);

      final viaWrapper = File('${tmp.path}/wrapper.bin');
      await processVideoPayload(
        srcPath: src.path,
        srcOffset: 0,
        length: original.length,
        dstPath: viaWrapper.path,
        phrase: 'pw',
        salt: s,
      ).done;

      final viaPackage = File('${tmp.path}/package.bin');
      await processVideoFile(
        srcPath: src.path,
        srcOffset: 0,
        length: original.length,
        dstPath: viaPackage.path,
        phrase: 'pw',
        salt: s,
        streamOffset: videoStreamDataOffset,
      ).done;

      expect(
        await viaWrapper.readAsBytes(),
        equals(await viaPackage.readAsBytes()),
      );
    }, skip: skip);

    test('append writes ciphertext after existing bytes in dstPath', () async {
      final original = Uint8List.fromList(List.generate(64, (i) => i));
      final src = File('${tmp.path}/src.bin');
      await src.writeAsBytes(original);
      final s = salt(5);

      final dst = File('${tmp.path}/dst.bin');
      final prefix = Uint8List.fromList([1, 2, 3, 4]);
      await dst.writeAsBytes(prefix);

      await processVideoPayload(
        srcPath: src.path,
        srcOffset: 0,
        length: original.length,
        dstPath: dst.path,
        phrase: 'pw',
        salt: s,
        append: true,
      ).done;

      final written = await dst.readAsBytes();
      expect(written.length, prefix.length + original.length);
      expect(written.sublist(0, prefix.length), equals(prefix));
    }, skip: skip);
  });
}
