import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

class _MockImageProcessingRepository extends Mock
    implements ImageProcessingRepository {}

class _MockStorageRepository extends Mock implements StorageRepository {}

class _FakeImageData extends Fake implements ImageData {}

void main() {
  late _MockImageProcessingRepository mockImageRepo;
  late _MockStorageRepository mockStorageRepo;
  late DecryptImageUseCase useCase;
  late File tFile;

  final tImageData = _FakeImageData();
  final tEncryptedData = _FakeImageData();
  final tEncoded = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(_FakeImageData());
  });

  setUp(() async {
    tFile = File(
      '${Directory.systemTemp.path}/decrypt_test_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tFile.create();
    mockImageRepo = _MockImageProcessingRepository();
    mockStorageRepo = _MockStorageRepository();
    useCase = DecryptImageUseCase(
      imageRepo: mockImageRepo,
      storageRepo: mockStorageRepo,
    );
  });

  tearDown(() async {
    if (await tFile.exists()) await tFile.delete();
  });

  group('DecryptImageUseCase.call', () {
    test('returns Right(BytesInfo) on full success', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);

      final result = await useCase.call(
        DecryptImageParams(file: tFile, password: 'secret'),
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Expected Right'), (bytesInfo) {
        expect(bytesInfo.bytes, tEncoded);
        expect(bytesInfo.hash, isNotEmpty);
      });
    });

    test('calls decode → encrypt → encode in order', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tEncryptedData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => tEncoded);

      await useCase.call(DecryptImageParams(file: tFile, password: 'pass'));

      verifyInOrder([
        () => mockImageRepo.decode(tFile),
        () => mockImageRepo.encrypt(tImageData, 'pass'),
        () => mockImageRepo.encode(tEncryptedData),
      ]);
    });

    test(
      'returns Left(unsupportedExtension) when decode returns null',
      () async {
        when(() => mockImageRepo.decode(tFile)).thenAnswer((_) async => null);

        final result = await useCase.call(
          DecryptImageParams(file: tFile, password: 'secret'),
        );

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<EncryptionFailure>());
          expect(failure.message, contains('png'));
        }, (_) => fail('Expected Left'));
        verifyNever(() => mockImageRepo.encrypt(any(), any()));
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
        DecryptImageParams(file: tFile, password: 'secret'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Encoding failed')),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(encryptionError) when decode throws', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenThrow(Exception('disk error'));

      final result = await useCase.call(
        DecryptImageParams(file: tFile, password: 'secret'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('disk error')),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(encryptionError) when encrypt throws', () async {
      when(
        () => mockImageRepo.decode(tFile),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenThrow(Exception('encrypt error'));

      final result = await useCase.call(
        DecryptImageParams(file: tFile, password: 'secret'),
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
