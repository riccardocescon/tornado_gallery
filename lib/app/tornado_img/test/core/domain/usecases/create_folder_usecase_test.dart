import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/create_folder_usecase.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late _MockStorageRepository repo;
  late CreateFolderUseCase useCase;

  setUp(() {
    repo = _MockStorageRepository();
    useCase = CreateFolderUseCase(storageRepo: repo);
  });

  test('creates folder at parent/name and returns Right(true)', () async {
    when(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    ).thenAnswer((_) async => true);

    final result = await useCase.call(
      CreateFolderParams(
        parentRelativePath: 'Vacanze',
        name: 'Mare',
        isPrivate: true,
      ),
    );

    expect(result, const Right<dynamic, bool>(true));
    verify(
      () => repo.createFolder(isPrivate: true, relativePath: 'Vacanze/Mare'),
    ).called(1);
  });

  test('uses bare name at root', () async {
    when(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    ).thenAnswer((_) async => true);

    await useCase.call(
      CreateFolderParams(parentRelativePath: '', name: 'Docs', isPrivate: false),
    );

    verify(
      () => repo.createFolder(isPrivate: false, relativePath: 'Docs'),
    ).called(1);
  });

  test('sanitizes illegal characters in the folder name', () async {
    when(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    ).thenAnswer((_) async => true);

    await useCase.call(
      CreateFolderParams(
        parentRelativePath: '',
        name: 'a/b:c',
        isPrivate: true,
      ),
    );

    verify(
      () => repo.createFolder(isPrivate: true, relativePath: 'a_b_c'),
    ).called(1);
  });

  test('returns Left when name is blank', () async {
    final result = await useCase.call(
      CreateFolderParams(parentRelativePath: '', name: '   ', isPrivate: true),
    );

    expect(result.isLeft(), isTrue);
    verifyNever(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    );
  });

  test('returns Left when repository reports failure', () async {
    when(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    ).thenAnswer((_) async => false);

    final result = await useCase.call(
      CreateFolderParams(parentRelativePath: '', name: 'X', isPrivate: true),
    );

    expect(result.isLeft(), isTrue);
  });

  test('returns Left when repository throws', () async {
    when(
      () => repo.createFolder(
        isPrivate: any(named: 'isPrivate'),
        relativePath: any(named: 'relativePath'),
      ),
    ).thenThrow(Exception('io error'));

    final result = await useCase.call(
      CreateFolderParams(parentRelativePath: '', name: 'X', isPrivate: true),
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f.message, contains('io error')),
      (_) => fail('expected Left'),
    );
  });
}
