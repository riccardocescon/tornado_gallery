import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class _MockEncryptImageUseCase extends Mock implements EncryptImageUseCase {}

class _MockDecryptImageUseCase extends Mock implements DecryptImageUseCase {}

void main() {
  late _MockEncryptImageUseCase mockEncryptionUseCase;
  late _MockDecryptImageUseCase mockDecryptUseCase;
  late GalleryImage tImage;

  final tFile = File('test_image.png');

  setUpAll(() {
    registerFallbackValue(
      EncryptImageParams(
        file: tFile,
        password: 'pw',
        fileId: 'img1',
        path: '/path',
      ),
    );
  });

  setUp(() {
    mockEncryptionUseCase = _MockEncryptImageUseCase();
    mockDecryptUseCase = _MockDecryptImageUseCase();
    tImage = GalleryImage(id: 'img1', file: tFile, date: DateTime(2024));
  });

  test('initial state is GalleryState.initial', () {
    final bloc = GalleryBloc(
      encryptUseCase: mockEncryptionUseCase,
      decryptUseCase: mockDecryptUseCase,
    );
    expect(bloc.state, const GalleryState.initial());
    bloc.close();
  });

  group('GalleryEvent.encryptImage', () {
    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encrypted] when use case succeeds',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer(
          (_) async => Right(
            GalleryImage(
              id: 'encrypted_img1',
              file: File('encrypted_img1.enc'),
              date: DateTime(2024),
            ),
          ),
        );
        return GalleryBloc(
          encryptUseCase: mockEncryptionUseCase,
          decryptUseCase: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImage(
              image: tImage,
              password: 'secret',
              path: '',
            ),
          ),
      expect:
          () => [
            GalleryState.loading(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [tImage],
                failedImages: [],
              ),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encryptionFailure] when use case returns Left',
      build: () {
        when(() => mockEncryptionUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('bad')),
        );
        return GalleryBloc(
          encryptUseCase: mockEncryptionUseCase,
          decryptUseCase: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImage(
              image: tImage,
              password: 'secret',
              path: '',
            ),
          ),
      expect:
          () => [
            const GalleryState.loading(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encryptionFailure: (f) => f.failure.message,
                orElse: () => '',
              ),
              'failure.message',
              contains('bad'),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encryptionFailure] for unsupported extension',
      build: () {
        when(() => mockEncryptionUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.unsupportedExtension('bmp')),
        );
        return GalleryBloc(
          encryptUseCase: mockEncryptionUseCase,
          decryptUseCase: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImage(
              image: tImage,
              password: 'secret',
              path: '/folder',
            ),
          ),
      expect:
          () => [
            const GalleryState.loading(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encryptionFailure: (f) => f.failure.message,
                orElse: () => '',
              ),
              'failure.message',
              contains('bmp'),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'passes correct params to use case',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer(
          (_) async => Right(
            GalleryImage(
              id: 'encrypted_img1',
              file: File('encrypted_img1.enc'),
              date: DateTime(2024),
            ),
          ),
        );
        return GalleryBloc(
          encryptUseCase: mockEncryptionUseCase,
          decryptUseCase: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImage(
              image: tImage,
              password: 'mypassword',
              path: '/my/path',
            ),
          ),
      verify: (_) {
        final captured =
            verify(() => mockEncryptionUseCase.call(captureAny())).captured;
        final params = captured.first as EncryptImageParams;
        expect(params.file, tFile);
        expect(params.password, 'mypassword');
        expect(params.fileId, 'img1');
        expect(params.path, '/my/path');
      },
    );
  });
}
