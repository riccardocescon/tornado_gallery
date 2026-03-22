import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository_impl.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';

class _MockImageProcessingRepository extends Mock
    implements ImageProcessingRepository {}

class _MockStorageRepository extends Mock implements StorageRepository {}

class _FakeImageData extends Fake implements ImageData {}

void main() {
  late _MockImageProcessingRepository mockImageRepo;
  late _MockStorageRepository mockStorageRepo;
  late EncryptImageUseCase useCase;

  final tFile = File('test.png');
  final tImageData = _FakeImageData();
  final tEncryptedData = _FakeImageData();
  final tEncoded = Uint8List.fromList([9, 8, 7]);

  setUpAll(() {
    registerFallbackValue(_FakeImageData());
    registerFallbackValue('');
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockImageRepo = _MockImageProcessingRepository();
    mockStorageRepo = _MockStorageRepository();
    useCase = EncryptImageUseCase(
      imageRepo: mockImageRepo,
      storageRepo: mockStorageRepo,
    );
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
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          path: '/my/folder',
        ),
      );

      expect(result, const Right(unit));
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
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          path: '/my/folder',
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
            path: '/path',
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
          path: '/path',
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
          path: '/path',
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
        ),
      ).thenThrow(Exception('save error'));

      final result = await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          path: '/path',
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
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        EncryptImageParams(
          file: tFile,
          password: 'secret',
          fileId: 'abc123',
          path: '',
        ),
      );

      verify(
        () => mockStorageRepo.save(
          bytes: tEncoded,
          fileName: 'abc123.png',
          path: '',
        ),
      ).called(1);
    });
  });
}
