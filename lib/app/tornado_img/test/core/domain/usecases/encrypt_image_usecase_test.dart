import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';

class _MockImageProcessingRepository extends Mock
    implements ImageProcessingRepository {}

class _MockStorageRepository extends Mock implements StorageRepository {}

class _FakeImageData extends Fake implements ImageData {}

void main() {
  late _MockImageProcessingRepository mockImageRepo;
  late _MockStorageRepository mockStorageRepo;
  late EncryptImageUseCase useCase;
  late File tFile;

  final tImageData = _FakeImageData();
  final tEncryptedData = _FakeImageData();
  final tEncoded = Uint8List.fromList([9, 8, 7]);

  setUpAll(() {
    registerFallbackValue(_FakeImageData());
    registerFallbackValue('');
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    tFile = File(
      '${Directory.systemTemp.path}/encrypt_test_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tFile.create();
    mockImageRepo = _MockImageProcessingRepository();
    mockStorageRepo = _MockStorageRepository();
    useCase = EncryptImageUseCase(
      imageRepo: mockImageRepo,
      storageRepo: mockStorageRepo,
    );
  });

  tearDown(() async {
    if (await tFile.exists()) await tFile.delete();
  });

  group('EncryptImageUseCase.call', () {
    test('returns Right(unit) on full success', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init().copyWith(
            outputFolder: '/my/folder',
          )
        ),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (encryptedImage) {
        expect(encryptedImage.storagePath.path, '/my/folder/abc123.png');
        expect(encryptedImage.encryptedInfo.bytes, tEncoded);
      });
      
    });

    test('calls repos in correct order with correct arguments', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init().copyWith(
            outputFolder: '/my/folder',
          ),
        ),
      );

      verifyInOrder([
        () => mockImageRepo.decode(tFile),
        () => mockImageRepo.encrypt(tImageData, 'secret'),
        () => mockImageRepo.encode(tEncryptedData),
        () => mockStorageRepo.save(
          bytes: tEncoded,
          fileName: 'abc123.png',
          path: '/my/folder',
          album: any(named: 'album'),
        ),
      ]);
    });

    test(
      'returns Left(unsupportedExtension) when decode returns null',
      () async {
        when(() => mockImageRepo.decode(tFile)).thenAnswer((_) async => null);

        final result = await useCase.call(
          EncryptImageParams(
            file: tFile,
            password: 'secret',
            fileId: 'abc123',
            settings: EncryptionSettings.init().copyWith(outputFolder: '/path'),
          ),
        );

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<EncryptionFailure>());
          expect(failure.message, contains('png'));
        }, (_) => fail('Expected Left'));
        verifyNever(() => mockImageRepo.encrypt(any(), any()));
        verifyNever(
          () => mockStorageRepo.save(
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
            path: any(named: 'path'),
            album: any(named: 'album'),
          ),
        );
      },
    );

    test('returns Left(encryptionError) when encode returns null', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => null);

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init().copyWith(outputFolder: '/path'),
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Encoding failed')),
        (_) => fail('Expected Left'),
      );
      verifyNever(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      );
    });

    test('returns Left(encryptionError) when decode throws', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenThrow(Exception('disk error'));

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init().copyWith(outputFolder: '/path'),
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<EncryptionFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(encryptionError) when save throws', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenThrow(Exception('save error'));

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init().copyWith(outputFolder: '/path'),
        ),
      );

      expect(result.isLeft(), isTrue);
    });

    test('uses null path when params.path is null', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          settings: EncryptionSettings.init(),
        ),
      );

      verify(
        () => mockStorageRepo.save(
          bytes: tEncoded,
          fileName: 'abc123.png',
          path: '',
          album: any(named: 'album'),
        ),
      ).called(1);
    });
  });
}
