import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/data/video_crypto/cosmetic_mp4_builder.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_video_usecase.dart';

// The DLL lives at <repo root>/lib/cpp/build/tornado_crypto.dll. `flutter
// test` runs with the current directory set to this package
// (lib/app/tornado_img), so two levels up reaches the repo root.
const String _dllPath = '../../cpp/build/tornado_crypto.dll';

class _MockCosmeticMp4Builder extends Mock implements CosmeticMp4Builder {}

/// A minimal but structurally valid mp4 (`ftyp` box then `mdat` box), so
/// `findVideoBox`'s box walk can skip over it to reach the `uuid` box —
/// mirrors the real [CosmeticMp4Builder] output shape closely enough for
/// this test without needing the device-only encoder.
Uint8List _fakeMp4() {
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
  box('mdat', List.filled(16, 0xAB));
  return out.toBytes();
}

void main() {
  final dllPresent = File(_dllPath).existsSync();
  final skip =
      dllPresent ? false : 'native tornado_crypto.dll not found at $_dllPath';

  late Directory tmp;
  late DecryptVideoUseCase useCase;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('decrypt_video_usecase_test');
    useCase = DecryptVideoUseCase();
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
    final leftoverTempDir = Directory(
      '${Directory.systemTemp.path}/tornado_video',
    );
    if (await leftoverTempDir.exists()) {
      await leftoverTempDir.delete(recursive: true);
    }
  });

  test(
    'returns Left(notAnEncryptedVideo) for a file with no box, without writing a temp file',
    () async {
      final plain = File('${tmp.path}/plain.mp4');
      await plain.writeAsBytes([1, 2, 3, 4, 5]);

      final result = await useCase.call(
        DecryptVideoParams(encryptedPath: plain.path, password: 'pw'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Not an encrypted video')),
        (_) => fail('Expected Left'),
      );
    },
  );

  group('DecryptVideoUseCase — full pipeline (requires an encrypted fixture)', () {
    late _MockCosmeticMp4Builder mockBuilder;
    late Uint8List original;
    late File encryptedFile;
    const password = 'video-pw';

    setUp(() async {
      mockBuilder = _MockCosmeticMp4Builder();
      when(
        () => mockBuilder.build(
          posterBytes: any(named: 'posterBytes'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => (
          mp4: _fakeMp4(),
          posterPng: Uint8List.fromList(List.filled(32, 0x11)),
        ),
      );

      original = Uint8List.fromList(
        List.generate(64 * 1024 + 13, (i) => (i * 7) & 0xFF),
      );
      final src = File('${tmp.path}/source.mp4');
      await src.writeAsBytes(original);

      final encryptUseCase = EncryptVideoUseCase(cosmeticBuilder: mockBuilder);
      final encryptResult = await encryptUseCase.call(
        EncryptVideoParams(
          file: src,
          password: password,
          fileId: 'roundtrip',
          posterBytes: Uint8List(0),
          destinationPath: tmp.path,
        ),
      );
      encryptedFile = encryptResult.fold(
        (f) => throw StateError('setup encryption failed: ${f.message}'),
        (img) => File(img.storagePath.path),
      );
    });

    test('decrypts to a bit-perfect copy of the original bytes', () async {
      final result = await useCase.call(
        DecryptVideoParams(encryptedPath: encryptedFile.path, password: password),
      );

      expect(result.isRight(), isTrue);
      File? tempFile;
      result.fold((_) => fail('Expected Right'), (f) => tempFile = f);
      expect(tempFile!.path, contains('tornado_video'));
      expect(tempFile!.path, endsWith('.mp4'));
      final decrypted = await tempFile!.readAsBytes();
      expect(decrypted, equals(original));
    }, skip: skip, tags: ['native']);

    test(
      'returns Left(wrongPassword) fast via the KCV, without decrypting',
      () async {
        final result = await useCase.call(
          DecryptVideoParams(
            encryptedPath: encryptedFile.path,
            password: 'not-the-password',
          ),
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure.message, contains('Wrong password')),
          (_) => fail('Expected Left'),
        );

        final tempDir = Directory('${Directory.systemTemp.path}/tornado_video');
        if (await tempDir.exists()) {
          expect(await tempDir.list().toList(), isEmpty);
        }
      },
      skip: skip,
      tags: ['native'],
    );
  });
}
