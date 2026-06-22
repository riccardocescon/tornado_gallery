import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/rename_folder_usecase.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late _MockStorageRepository repo;
  late RenameFolderUsecase useCase;

  setUp(() {
    repo = _MockStorageRepository();
    useCase = RenameFolderUsecase(storageRepo: repo);
  });

  test('renames a nested folder keeping its parent path', () async {
    when(
      () => repo.renameFolder(
        isPrivate: any(named: 'isPrivate'),
        oldRelativePath: any(named: 'oldRelativePath'),
        newRelativePath: any(named: 'newRelativePath'),
      ),
    ).thenAnswer((_) async => true);

    final result = await useCase.call(
      RenameFolderParams(
        relativePath: 'Vacanze/Old',
        newName: 'New',
        isPrivate: true,
      ),
    );

    expect(result, const Right<dynamic, bool>(true));
    verify(
      () => repo.renameFolder(
        isPrivate: true,
        oldRelativePath: 'Vacanze/Old',
        newRelativePath: 'Vacanze/New',
      ),
    ).called(1);
  });

  test('renames a top-level folder', () async {
    when(
      () => repo.renameFolder(
        isPrivate: any(named: 'isPrivate'),
        oldRelativePath: any(named: 'oldRelativePath'),
        newRelativePath: any(named: 'newRelativePath'),
      ),
    ).thenAnswer((_) async => true);

    await useCase.call(
      RenameFolderParams(relativePath: 'Old', newName: 'New', isPrivate: true),
    );

    verify(
      () => repo.renameFolder(
        isPrivate: true,
        oldRelativePath: 'Old',
        newRelativePath: 'New',
      ),
    ).called(1);
  });

  test('returns Left when name is blank', () async {
    final result = await useCase.call(
      RenameFolderParams(relativePath: 'Old', newName: '  ', isPrivate: true),
    );
    expect(result.isLeft(), isTrue);
    verifyNever(
      () => repo.renameFolder(
        isPrivate: any(named: 'isPrivate'),
        oldRelativePath: any(named: 'oldRelativePath'),
        newRelativePath: any(named: 'newRelativePath'),
      ),
    );
  });

  test('returns Left when trying to rename the root', () async {
    final result = await useCase.call(
      RenameFolderParams(relativePath: '', newName: 'X', isPrivate: true),
    );
    expect(result.isLeft(), isTrue);
  });

  test('returns Left when repository reports failure', () async {
    when(
      () => repo.renameFolder(
        isPrivate: any(named: 'isPrivate'),
        oldRelativePath: any(named: 'oldRelativePath'),
        newRelativePath: any(named: 'newRelativePath'),
      ),
    ).thenAnswer((_) async => false);

    final result = await useCase.call(
      RenameFolderParams(relativePath: 'Old', newName: 'New', isPrivate: true),
    );
    expect(result.isLeft(), isTrue);
  });
}
