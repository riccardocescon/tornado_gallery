import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/delete_folder_usecase.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

EncryptedImage _img(String path, {String? assetId}) => EncryptedImage(
  storagePath: StoragePath(
    path: path,
    isPrivateFolder: assetId == null,
    assetId: assetId,
  ),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

void main() {
  late _MockStorageRepository repo;
  late DeleteFolderUsecase useCase;

  setUpAll(() => registerFallbackValue(<StoragePath>[]));

  setUp(() {
    repo = _MockStorageRepository();
    useCase = DeleteFolderUsecase(storageRepo: repo);
  });

  test('deletes folder and forwards contained storage paths', () async {
    when(
      () => repo.deleteFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
        contained: any(named: 'contained'),
      ),
    ).thenAnswer((_) async => true);

    final contained = [_img('/enc/Vacanze/a.png', assetId: 'id1')];
    final result = await useCase.call(
      DeleteFolderParams(
        relativePath: 'Vacanze',
        isPrivate: false,
        contained: contained,
      ),
    );

    expect(result, const Right<dynamic, bool>(true));
    verify(
      () => repo.deleteFolder(
        isPrivate: false,
        relativePath: 'Vacanze',
        contained: [contained.first.storagePath],
      ),
    ).called(1);
  });

  test('returns Left when trying to delete root', () async {
    final result = await useCase.call(
      DeleteFolderParams(relativePath: '', isPrivate: true),
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => repo.deleteFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
        contained: any(named: 'contained'),
      ),
    );
  });

  test('returns Left when repository reports failure', () async {
    when(
      () => repo.deleteFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
        contained: any(named: 'contained'),
      ),
    ).thenAnswer((_) async => false);

    final result = await useCase.call(
      DeleteFolderParams(relativePath: 'X', isPrivate: true),
    );
    expect(result.isLeft(), isTrue);
  });
}
