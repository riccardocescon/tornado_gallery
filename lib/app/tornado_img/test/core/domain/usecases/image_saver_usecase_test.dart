import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

class _MockStorageRepository extends Mock implements StorageRepository {}

void main() {
  late _MockStorageRepository mockStorageRepo;
  late ImageSaverUsecase useCase;

  final tBytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockStorageRepo = _MockStorageRepository();
    useCase = ImageSaverUsecase(storageRepo: mockStorageRepo);
  });

  group('ImageSaverUsecase.call', () {
    test('returns Right(null) when storage saves successfully', () async {
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.call(
        ImageSaverParams.gallery(bytes: tBytes, fileName: 'image.png'),
      );

      expect(result.isRight(), isTrue);
    });

    test('strips extension from fileName before saving', () async {
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        ImageSaverParams.gallery(bytes: tBytes, fileName: 'photo.png'),
      );

      verify(
        () => mockStorageRepo.save(
          bytes: tBytes,
          fileName: 'photo',
          path: null,
          album: null,
        ),
      );
    });

    test('appFolder mode preserves extension and passes path to storage', () async {
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenAnswer((_) async {});

      await useCase.call(
        ImageSaverParams.appFolder(
          bytes: tBytes,
          fileName: 'photo.png',
          path: '/private/folder',
        ),
      );

      verify(
        () => mockStorageRepo.save(
          bytes: tBytes,
          fileName: 'photo.png',
          path: '/private/folder',
          album: null,
        ),
      );
    });

    test('returns Left(encryptionError) when storage throws', () async {
      when(
        () => mockStorageRepo.save(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
          path: any(named: 'path'),
          album: any(named: 'album'),
        ),
      ).thenThrow(Exception('write error'));

      final result = await useCase.call(
        ImageSaverParams.gallery(bytes: tBytes, fileName: 'image.png'),
      );

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure, isA<EncryptionFailure>());
        expect(failure.message, contains('write error'));
      }, (_) => fail('Expected Left'));
    });
  });
}
