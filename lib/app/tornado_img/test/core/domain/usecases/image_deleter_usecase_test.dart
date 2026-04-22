import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late _MockStorageRepository mockStorageRepo;
  late ImageDeleterUsecase useCase;

  setUp(() {
    mockStorageRepo = _MockStorageRepository();
    useCase = ImageDeleterUsecase(storageRepo: mockStorageRepo);
  });

  group('ImageDeleterUsecase.call', () {
    test('returns Right(true) when storage deletes successfully', () async {
      when(
        () => mockStorageRepo.delete(any(), assetId: any(named: 'assetId')),
      ).thenAnswer((_) async => true);

      final result = await useCase.call(
        ImageDeleterParams(path: '/path/image.png'),
      );

      expect(result, equals(const Right<EncryptionFailure, bool>(true)));
      verify(() => mockStorageRepo.delete('/path/image.png', assetId: null));
    });

    test('returns Right(false) when storage reports file not found', () async {
      when(
        () => mockStorageRepo.delete(any(), assetId: any(named: 'assetId')),
      ).thenAnswer((_) async => false);

      final result = await useCase.call(
        ImageDeleterParams(path: '/path/image.png'),
      );

      expect(result, equals(const Right<EncryptionFailure, bool>(false)));
    });

    test('passes assetId to storage when provided', () async {
      when(
        () => mockStorageRepo.delete(any(), assetId: any(named: 'assetId')),
      ).thenAnswer((_) async => true);

      await useCase.call(
        ImageDeleterParams(path: '/path/image.png', assetId: 'asset_123'),
      );

      verify(
        () => mockStorageRepo.delete('/path/image.png', assetId: 'asset_123'),
      );
    });

    test('returns Left(encryptionError) when storage throws', () async {
      when(
        () => mockStorageRepo.delete(any(), assetId: any(named: 'assetId')),
      ).thenThrow(Exception('disk full'));

      final result = await useCase.call(
        ImageDeleterParams(path: '/path/image.png'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('disk full')),
        (_) => fail('Expected Left'),
      );
    });
  });
}
