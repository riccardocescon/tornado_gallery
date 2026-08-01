import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';

/// XORs each byte against the repeating phrase, byte-for-byte. Symmetric,
/// deterministic, and cheap — lets the streaming/chunking logic be tested
/// without the native DLL.
Future<Uint8List> _fakeXor(Uint8List input, String phrase) async {
  final key = phrase.codeUnits;
  return Uint8List.fromList([
    for (var i = 0; i < input.length; i++) input[i] ^ key[i % key.length],
  ]);
}

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('video_cipher_test');
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Uint8List salt([int seed = 1]) =>
      Uint8List.fromList(List.generate(16, (i) => (i + seed) & 0xFF));

  group('VideoCipher.hex', () {
    test('is lowercase, zero-padded, and unseparated', () {
      final bytes = Uint8List.fromList([0, 1, 0xAB, 0xFF]);
      expect(VideoCipher.hex(bytes), '0001abff');
    });
  });

  group('VideoCipher.chunkPhrase', () {
    test('differs across chunk indexes', () {
      final s = salt();
      final p0 = VideoCipher.chunkPhrase('pw', s, 0);
      final p1 = VideoCipher.chunkPhrase('pw', s, 1);
      expect(p0, isNot(equals(p1)));
    });

    test('differs across salts', () {
      final p0 = VideoCipher.chunkPhrase('pw', salt(1), 0);
      final p1 = VideoCipher.chunkPhrase('pw', salt(2), 0);
      expect(p0, isNot(equals(p1)));
    });
  });

  group('VideoCipher.process (fake processor)', () {
    Future<File> writeRandomFile(String name, int length) async {
      final bytes = Uint8List.fromList(
        List.generate(length, (i) => (i * 31 + 7) & 0xFF),
      );
      final file = File('${tmp.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    }

    Future<File> runCipher(
      VideoCipher cipher,
      File src,
      String outName, {
      required int totalBytes,
      required String phrase,
      required Uint8List salt,
      required int chunkSize,
    }) async {
      final out = File('${tmp.path}/$outName');
      final raf = await src.open();
      final sink = out.openWrite();
      try {
        await cipher.process(
          src: raf,
          out: sink,
          totalBytes: totalBytes,
          phrase: phrase,
          salt: salt,
          chunkSize: chunkSize,
        );
      } finally {
        await raf.close();
        await sink.close();
      }
      return out;
    }

    test(
      'roundtrips a 10 MiB + 3 byte file through a partial last chunk',
      () async {
        const totalBytes = 10 * 1024 * 1024 + 3;
        const chunkSize = 4 * 1024 * 1024;
        final srcFile = await writeRandomFile('plain.bin', totalBytes);
        final original = await srcFile.readAsBytes();
        final s = salt();
        final cipher = VideoCipher(processor: _fakeXor);

        final encFile = await runCipher(
          cipher,
          srcFile,
          'enc.bin',
          totalBytes: totalBytes,
          phrase: 'pw',
          salt: s,
          chunkSize: chunkSize,
        );
        final encrypted = await encFile.readAsBytes();
        expect(encrypted.length, totalBytes);
        expect(encrypted, isNot(equals(original)));

        final decFile = await runCipher(
          cipher,
          encFile,
          'dec.bin',
          totalBytes: totalBytes,
          phrase: 'pw',
          salt: s,
          chunkSize: chunkSize,
        );
        final decrypted = await decFile.readAsBytes();
        expect(decrypted, equals(original));
      },
    );

    test('output length equals input length for a whole-chunk file', () async {
      const totalBytes = 4 * 1024 * 1024; // exactly one chunk
      final srcFile = await writeRandomFile('exact.bin', totalBytes);
      final cipher = VideoCipher(processor: _fakeXor);

      final outFile = await runCipher(
        cipher,
        srcFile,
        'exact_out.bin',
        totalBytes: totalBytes,
        phrase: 'pw',
        salt: salt(),
        chunkSize: totalBytes,
      );

      expect(await outFile.length(), totalBytes);
    });

    test('output length equals input length for a small file', () async {
      const totalBytes = 100;
      final srcFile = await writeRandomFile('small.bin', totalBytes);
      final cipher = VideoCipher(processor: _fakeXor);

      final outFile = await runCipher(
        cipher,
        srcFile,
        'small_out.bin',
        totalBytes: totalBytes,
        phrase: 'pw',
        salt: salt(),
        chunkSize: 4 * 1024 * 1024,
      );

      expect(await outFile.length(), totalBytes);
    });

    test('processes zero bytes as a no-op', () async {
      final srcFile = await writeRandomFile('empty.bin', 0);
      final cipher = VideoCipher(processor: _fakeXor);

      final outFile = await runCipher(
        cipher,
        srcFile,
        'empty_out.bin',
        totalBytes: 0,
        phrase: 'pw',
        salt: salt(),
        chunkSize: 4 * 1024 * 1024,
      );

      expect(await outFile.length(), 0);
    });
  });

  group('VideoCipher key check value', () {
    test('same phrase and salt give the same kcv', () async {
      final s = salt();
      final k1 = await VideoCipher.keyCheckValue(
        'pw',
        s,
        processor: _fakeXor,
      );
      final k2 = await VideoCipher.keyCheckValue(
        'pw',
        s,
        processor: _fakeXor,
      );
      expect(k1, equals(k2));
    });

    test('a different phrase gives a different kcv', () async {
      final s = salt();
      final k1 = await VideoCipher.keyCheckValue(
        'pw1',
        s,
        processor: _fakeXor,
      );
      final k2 = await VideoCipher.keyCheckValue(
        'pw2',
        s,
        processor: _fakeXor,
      );
      expect(k1, isNot(equals(k2)));
    });

    test('a different salt gives a different kcv', () async {
      final k1 = await VideoCipher.keyCheckValue(
        'pw',
        salt(1),
        processor: _fakeXor,
      );
      final k2 = await VideoCipher.keyCheckValue(
        'pw',
        salt(2),
        processor: _fakeXor,
      );
      expect(k1, isNot(equals(k2)));
    });

    test('matchesKeyCheckValue is true for a matching password', () async {
      final s = salt();
      final kcv = await VideoCipher.keyCheckValue(
        'pw',
        s,
        processor: _fakeXor,
      );
      final result = await VideoCipher.matchesKeyCheckValue(
        'pw',
        s,
        kcv,
        processor: _fakeXor,
      );
      expect(result, isTrue);
    });

    test('matchesKeyCheckValue is false for a wrong password', () async {
      final s = salt();
      final kcv = await VideoCipher.keyCheckValue(
        'pw',
        s,
        processor: _fakeXor,
      );
      final result = await VideoCipher.matchesKeyCheckValue(
        'wrong',
        s,
        kcv,
        processor: _fakeXor,
      );
      expect(result, isFalse);
    });
  });
}
