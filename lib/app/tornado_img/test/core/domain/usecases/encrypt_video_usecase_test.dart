import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tornado_img_app/core/data/video_crypto/cosmetic_mp4_builder.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_box_codec.dart';
import 'package:tornado_img_app/core/data/video_crypto/video_cipher.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_video_usecase.dart';
import 'package:tornado_img_app/core/utils/constants.dart';

// The DLL lives at <repo root>/lib/cpp/build/tornado_crypto.dll. `flutter
// test` runs with the current directory set to this package
// (lib/app/tornado_img), so two levels up reaches the repo root.
const String _dllPath = '../../cpp/build/tornado_crypto.dll';

class _MockCosmeticMp4Builder extends Mock implements CosmeticMp4Builder {}

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// A minimal but structurally valid mp4 (`ftyp` box then `mdat` box), so
/// `findVideoBox`'s box walk can skip over it to reach our `uuid` box —
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

  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late _MockCosmeticMp4Builder mockBuilder;
  late EncryptVideoUseCase useCase;
  final tCosmetic = _fakeMp4();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('encrypt_video_usecase_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tmp.path);
    mockBuilder = _MockCosmeticMp4Builder();
    useCase = EncryptVideoUseCase(cosmeticBuilder: mockBuilder);
    when(
      () => mockBuilder.build(
        posterBytes: any(named: 'posterBytes'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => tCosmetic);
  });

  tearDown(() async {
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Future<File> writeSource(String name, List<int> content) async {
    final f = File('${tmp.path}/$name');
    await f.writeAsBytes(content);
    return f;
  }

  group('EncryptVideoUseCase.call — validation (no native calls)', () {
    test('returns Left(fileTooLarge) for a file over maxVideoBytes', () async {
      final src = File('${tmp.path}/huge.mp4');
      final raf = await src.open(mode: FileMode.write);
      await raf.truncate(Constants.maxVideoBytes + 1);
      await raf.close();

      final result = await useCase.call(
        EncryptVideoParams(
          file: src,
          password: 'secret',
          fileId: 'vid1',
          posterBytes: Uint8List(0),
          destinationPath: tmp.path,
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('too large')),
        (_) => fail('Expected Left'),
      );
      verifyNever(
        () => mockBuilder.build(
          posterBytes: any(named: 'posterBytes'),
          password: any(named: 'password'),
        ),
      );
    });

    test(
      'propagates a Left and leaves no output file when the cosmetic builder throws',
      () async {
        when(
          () => mockBuilder.build(
            posterBytes: any(named: 'posterBytes'),
            password: any(named: 'password'),
          ),
        ).thenThrow(StateError('poster decode failed'));

        final src = await writeSource('small.mp4', [1, 2, 3, 4]);

        final result = await useCase.call(
          EncryptVideoParams(
            file: src,
            password: 'secret',
            fileId: 'vid2',
            posterBytes: Uint8List(0),
            destinationPath: tmp.path,
          ),
        );

        expect(result.isLeft(), isTrue);
        expect(await File('${tmp.path}/vid2.mp4').exists(), isFalse);
      },
    );

    test(
      'deletes the partial output file when buildVideoBoxPrefix rejects the '
      'header synchronously (no DLL involved)',
      () async {
        // A non-ASCII extension makes buildVideoBoxPrefix throw ArgumentError
        // *after* the use case has already written the cosmetic bytes to
        // outputFile (see the two-step write in encrypt_video_usecase.dart) —
        // exactly the window the catch/delete branch exists to clean up.
        // Pure synchronous Dart validation: no native cipher call is reached.
        final src = await writeSource('badext.mp4é', [1, 2, 3, 4]);

        final result = await useCase.call(
          EncryptVideoParams(
            file: src,
            password: 'secret',
            fileId: 'vid5',
            posterBytes: Uint8List(0),
            destinationPath: tmp.path,
          ),
        );

        expect(result.isLeft(), isTrue);
        expect(await File('${tmp.path}/vid5.mp4').exists(), isFalse);
      },
    );
  });

  group('EncryptVideoUseCase.call — full pipeline', () {
    // These exercise the real native cipher (processVideoPayload), so they
    // need the DLL — same `skip` guard as video_cipher_test.dart, plus the
    // `native` tag so `flutter test --tags native` selects them too.

    test(
      'writes cosmetic-prefixed output with a box findVideoBox can parse',
      () async {
        final original = Uint8List.fromList(
          List.generate(1000, (i) => i & 0xFF),
        );
        final src = await writeSource('source.mp4', original);

        final result = await useCase.call(
          EncryptVideoParams(
            file: src,
            password: 'video-pw',
            fileId: 'vid3',
            posterBytes: Uint8List(0),
            destinationPath: tmp.path,
          ),
        );

        expect(result.isRight(), isTrue);
        final outFile = File('${tmp.path}/vid3.mp4');
        expect(await outFile.exists(), isTrue);

        final bytes = await outFile.readAsBytes();
        expect(bytes.sublist(0, tCosmetic.length), equals(tCosmetic));

        final raf = await outFile.open();
        final parsed = await findVideoBox(raf);
        await raf.close();

        expect(parsed, isNotNull);
        expect(parsed!.header.originalSize, original.length);
        expect(parsed.header.originalExt, 'mp4');
        expect(
          matchesVideoKeyCheckValue(
            'video-pw',
            parsed.header.salt,
            parsed.header.kcv,
          ),
          isTrue,
        );

        result.fold((_) => fail('Expected Right'), (encryptedImage) {
          expect(encryptedImage.storagePath.path, outFile.path);
          expect(encryptedImage.storagePath.isPrivateFolder, isTrue);
          expect(encryptedImage.encryptedInfo.bytes, tCosmetic);
        });
      },
      skip: skip,
      tags: ['native'],
    );

    test('defaults to the private folder when destinationPath is null', () async {
      final src = await writeSource('source2.mp4', [1, 2, 3]);

      final result = await useCase.call(
        EncryptVideoParams(
          file: src,
          password: 'video-pw',
          fileId: 'vid4',
          posterBytes: Uint8List(0),
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (encryptedImage) {
        expect(encryptedImage.storagePath.path, contains('vid4.mp4'));
        // No destinationPath given: falls back to the private `encrypted/`
        // root under the (faked) app documents dir, not the source's tmp dir.
        expect(
          encryptedImage.storagePath.path.replaceAll('\\', '/'),
          contains('/encrypted/'),
        );
      });
    }, skip: skip, tags: ['native']);
  });
}
