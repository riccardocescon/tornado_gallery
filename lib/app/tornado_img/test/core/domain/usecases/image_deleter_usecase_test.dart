import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

EncryptedImage _makeImage(String path, {String? assetId}) => EncryptedImage(
  storagePath: StoragePath(
    path: path,
    isPrivateFolder: false,
    assetId: assetId,
  ),
  date: DateTime(2024),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: 'hash'),
);

void main() {
  late _MockStorageRepository mockStorageRepo;
  late ImageDeleterUsecase useCase;

  setUp(() {
    mockStorageRepo = _MockStorageRepository();
    useCase = ImageDeleterUsecase(storageRepo: mockStorageRepo);
  });

  setUpAll(() {
    registerFallbackValue(<StoragePath>[]);
  });

  group('ImageDeleterUsecase.call', () {
    test('returns Right(true) when storage deletes successfully', () async {
      when(
        () => mockStorageRepo.delete(any()),
      ).thenAnswer((_) async => true);

      final image = _makeImage('/path/image.png');
      final result = await useCase.call(ImageDeleterParams(images: [image]));

      expect(result, equals(const Right<EncryptionFailure, bool>(true)));
      verify(() => mockStorageRepo.delete([image.storagePath]));
    });

    test('returns Right(false) when storage reports file not found', () async {
      when(
        () => mockStorageRepo.delete(any()),
      ).thenAnswer((_) async => false);

      final image = _makeImage('/path/image.png');
      final result = await useCase.call(ImageDeleterParams(images: [image]));

      expect(result, equals(const Right<EncryptionFailure, bool>(false)));
    });

    test('passes storagePath with assetId to storage when provided', () async {
      when(
        () => mockStorageRepo.delete(any()),
      ).thenAnswer((_) async => true);

      final image = _makeImage('/path/image.png', assetId: 'asset_123');
      await useCase.call(ImageDeleterParams(images: [image]));

      verify(
        () => mockStorageRepo.delete([image.storagePath]),
      );
    });

    test('passes all storagePaths in a single repo call for multi-image delete', () async {
      when(
        () => mockStorageRepo.delete(any()),
      ).thenAnswer((_) async => true);

      final image1 = _makeImage('/path/img1.png');
      final image2 = _makeImage('/path/img2.png');
      final image3 = _makeImage('/path/img3.png', assetId: 'asset_abc');

      await useCase.call(ImageDeleterParams(images: [image1, image2, image3]));

      verify(
        () => mockStorageRepo.delete([
          image1.storagePath,
          image2.storagePath,
          image3.storagePath,
        ]),
      ).called(1);
    });

    test('returns Left(encryptionError) when storage throws', () async {
      when(
        () => mockStorageRepo.delete(any()),
      ).thenThrow(Exception('disk full'));

      final image = _makeImage('/path/image.png');
      final result = await useCase.call(ImageDeleterParams(images: [image]));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('disk full')),
        (_) => fail('Expected Left'),
      );
    });
  });
}
