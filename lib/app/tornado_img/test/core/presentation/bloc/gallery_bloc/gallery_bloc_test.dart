import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class _MockEncryptImageUseCase extends Mock implements EncryptImageUseCase {}

void main() {
  late _MockEncryptImageUseCase mockUseCase;
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
    mockUseCase = _MockEncryptImageUseCase();
    tImage = GalleryImage(id: 'img1', file: tFile, date: DateTime(2024));
  });

  test('initial state is GalleryState.initial', () {
    final bloc = GalleryBloc(mockUseCase);
    expect(bloc.state, const GalleryState.initial());
    bloc.close();
  });

  group('GalleryEvent.encryptImage', () {
    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encrypted] when use case succeeds',
      build: () {
        when(
          () => mockUseCase.call(any()),
        ).thenAnswer((_) async => const Right(null));
        return GalleryBloc(mockUseCase);
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
            GalleryState.loading(),
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
        when(() => mockUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('bad')),
        );
        return GalleryBloc(mockUseCase);
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
            const GalleryState.loading(),
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
        when(() => mockUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.unsupportedExtension('bmp')),
        );
        return GalleryBloc(mockUseCase);
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
            const GalleryState.loading(),
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
          () => mockUseCase.call(any()),
        ).thenAnswer((_) async => const Right(unit));
        return GalleryBloc(mockUseCase);
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
        final captured = verify(() => mockUseCase.call(captureAny())).captured;
        final params = captured.first as EncryptImageParams;
        expect(params.file, tFile);
        expect(params.password, 'mypassword');
        expect(params.fileId, 'img1');
        expect(params.path, '/my/path');
      },
    );
  });
}
