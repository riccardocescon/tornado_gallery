import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_crypto/tornado_img_crypto.dart';

void main() {
  group('Tornado Crypto FFI Tests', () {
    late String testPhrase;

    setUp(() {
      testPhrase = 'test_key_123';
    });

    test('Basic Encryption/Decryption Reversibility', () async {
      final input = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      final encrypted = await processImage(input: input, phrase: testPhrase);

      expect(encrypted, isNot(equals(input)));

      // AES-CTR XOR is symmetric: applying twice restores the original
      final decrypted = await processImage(
        input: encrypted,
        phrase: testPhrase,
      );

      expect(decrypted, equals(input));
    });

    test('Output length matches input length', () async {
      final input = Uint8List.fromList([10, 20, 30, 40, 50]);

      final encrypted = await processImage(input: input, phrase: testPhrase);

      expect(encrypted.length, equals(input.length));
    });

    test('Large Data Encryption/Decryption Reversibility', () async {
      final largeData = Uint8List.fromList(
        List.generate(10000, (i) => i % 256),
      );

      final encrypted = await processImage(
        input: largeData,
        phrase: testPhrase,
      );
      expect(encrypted, isNot(equals(largeData)));

      final decrypted = await processImage(
        input: encrypted,
        phrase: testPhrase,
      );
      expect(decrypted, equals(largeData));
    });

    test('Large Data Performance', () async {
      final largeData = Uint8List.fromList(
        List.generate(10000, (i) => i % 256),
      );

      final start = DateTime.now();
      await processImage(input: largeData, phrase: testPhrase);
      final duration = DateTime.now().difference(start);

      expect(duration.inMilliseconds, lessThan(1000));
    });

    test('Encrypted output differs significantly from input', () async {
      // 300 bytes with a highly repetitive pattern
      final data = Uint8List(300);
      for (int i = 0; i < data.length; i += 6) {
        if (i + 5 < data.length) {
          data[i] = 255;
          data[i + 1] = 0;
          data[i + 2] = 0;
          data[i + 3] = 0;
          data[i + 4] = 0;
          data[i + 5] = 255;
        }
      }

      final encrypted = await processImage(input: data, phrase: testPhrase);

      // AES-256-CTR keystream is pseudorandom; the fraction of bytes that
      // happen to be within ±50 of the original is expected to be ~20%.
      // A threshold of 30% gives comfortable margin while catching regressions.
      int similar = 0;
      for (int i = 0; i < data.length; i++) {
        if ((data[i] - encrypted[i]).abs() < 50) similar++;
      }
      final similarityPct = (similar / data.length) * 100;
      expect(similarityPct, lessThan(30.0));
    });

    test('Different Keys Produce Different Results', () async {
      final input = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      final encrypted1 = await processImage(input: input, phrase: 'key1');
      final encrypted2 = await processImage(input: input, phrase: 'key2');

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('Same Key Always Produces Same Result (Deterministic)', () async {
      final input = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      final result1 = await processImage(input: input, phrase: testPhrase);
      final result2 = await processImage(input: input, phrase: testPhrase);

      expect(result1, equals(result2));
    });

    test('Empty Data Handling', () async {
      expect(
        () async => await processImage(input: Uint8List(0), phrase: testPhrase),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Empty Phrase Handling', () async {
      expect(
        () async => await processImage(
          input: Uint8List.fromList([1, 2, 3, 4, 5]),
          phrase: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Invalid Thread Count Handling', () async {
      final input = Uint8List.fromList([1, 2, 3, 4, 5]);

      expect(
        () async =>
            await processImage(input: input, phrase: testPhrase, numThreads: 0),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () async => await processImage(
          input: input,
          phrase: testPhrase,
          numThreads: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Progress Callback receives values in [0, 1]', () async {
      final input = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      final progressValues = <double>[];

      await processImage(
        input: input,
        phrase: testPhrase,
        onProgress: progressValues.add,
      );

      expect(progressValues, isNotEmpty);
      for (final p in progressValues) {
        expect(p, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  test("Version Test", () {
    final version = getVersion();
    print('Tornado Crypto SDK Version: $version');
    expect(version, isNotEmpty);
  });
}
