@Tags(['native'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';

// The DLL lives at <repo root>/lib/cpp/build/tornado_crypto.dll. `flutter
// test` runs with the current directory set to this package
// (lib/app/tornado_img), so two levels up reaches the repo root.
const String _dllPath = '../../cpp/build/tornado_crypto.dll';

void main() {
  final dllPresent = File(_dllPath).existsSync();

  test(
    'roundtrips 1 MiB through the real native engine',
    () async {
      final tmp = await Directory.systemTemp.createTemp(
        'video_cipher_native_test',
      );
      try {
        const totalBytes = 1024 * 1024;
        final original = Uint8List.fromList(
          List.generate(totalBytes, (i) => (i * 17 + 3) & 0xFF),
        );
        final srcFile = File('${tmp.path}/plain.bin');
        await srcFile.writeAsBytes(original);

        final salt = Uint8List.fromList(List.generate(16, (i) => i));
        final cipher = VideoCipher(); // real processImage, no fake injected

        final encFile = File('${tmp.path}/enc.bin');
        final encRaf = await srcFile.open();
        final encSink = encFile.openWrite();
        await cipher.process(
          src: encRaf,
          out: encSink,
          totalBytes: totalBytes,
          phrase: 'correct horse battery staple',
          salt: salt,
          chunkSize: 256 * 1024,
        );
        await encRaf.close();
        await encSink.close();

        final encrypted = await encFile.readAsBytes();
        expect(encrypted.length, totalBytes);
        expect(encrypted, isNot(equals(original)));

        final decFile = File('${tmp.path}/dec.bin');
        final decRaf = await encFile.open();
        final decSink = decFile.openWrite();
        await cipher.process(
          src: decRaf,
          out: decSink,
          totalBytes: totalBytes,
          phrase: 'correct horse battery staple',
          salt: salt,
          chunkSize: 256 * 1024,
        );
        await decRaf.close();
        await decSink.close();

        final decrypted = await decFile.readAsBytes();
        expect(decrypted, equals(original));
      } finally {
        await tmp.delete(recursive: true);
      }
    },
    skip: dllPresent
        ? false
        : 'native tornado_crypto.dll not found at $_dllPath',
  );
}
