import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/move_images_usecase.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

EncryptedImage _img(String path) => EncryptedImage(
  storagePath: StoragePath(path: path, isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

void main() {
  late _MockStorageRepository repo;
  late MoveImagesUseCase useCase;

  setUpAll(() => registerFallbackValue(<EncryptedImage>[]));

  setUp(() {
    repo = _MockStorageRepository();
    useCase = MoveImagesUseCase(storageRepo: repo);
  });

  test('moves images and returns the StorageMoveResult', () async {
    final moved = const StorageMoveResult(
      success: true,
      movedPrivatePaths: {'/enc/a.png': '/enc/Vacanze/a.png'},
    );
    when(
      () => repo.moveImages(
        images: any(named: 'images'),
        targetRelativePath: any(named: 'targetRelativePath'),
      ),
    ).thenAnswer((_) async => moved);

    final result = await useCase.call(
      MoveImagesParams(
        images: [_img('/enc/a.png')],
        targetRelativePath: 'Vacanze',
      ),
    );

    expect(result, Right<dynamic, StorageMoveResult>(moved));
    verify(
      () => repo.moveImages(
        images: any(named: 'images'),
        targetRelativePath: 'Vacanze',
      ),
    ).called(1);
  });

  test('returns Left(false-result) when no images provided', () async {
    final result = await useCase.call(
      MoveImagesParams(images: [], targetRelativePath: 'X'),
    );
    expect(result.isRight(), isTrue);
    verifyNever(
      () => repo.moveImages(
        images: any(named: 'images'),
        targetRelativePath: any(named: 'targetRelativePath'),
      ),
    );
  });

  test('returns Left when repository reports no move', () async {
    when(
      () => repo.moveImages(
        images: any(named: 'images'),
        targetRelativePath: any(named: 'targetRelativePath'),
      ),
    ).thenAnswer((_) async => const StorageMoveResult(success: false));

    final result = await useCase.call(
      MoveImagesParams(images: [_img('/enc/a.png')], targetRelativePath: 'X'),
    );
    expect(result.isLeft(), isTrue);
  });

  test('returns Left when repository throws', () async {
    when(
      () => repo.moveImages(
        images: any(named: 'images'),
        targetRelativePath: any(named: 'targetRelativePath'),
      ),
    ).thenThrow(Exception('boom'));

    final result = await useCase.call(
      MoveImagesParams(images: [_img('/enc/a.png')], targetRelativePath: 'X'),
    );
    expect(result.isLeft(), isTrue);
  });
}
