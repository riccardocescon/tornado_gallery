import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';

class _MockGalleryReaderUsecase extends Mock implements GalleryReaderUsecase {}

class _MockImageDeleterUsecase extends Mock implements ImageDeleterUsecase {}

class _MockImageSaverUsecase extends Mock implements ImageSaverUsecase {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockGalleryBloc extends Mock implements GalleryBloc {}

EncryptedImage _makeImage(String path) => EncryptedImage(
  storagePath: StoragePath(
    path: path,
    isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

EncryptedStreamImage _makeStreamImage(String path) =>
    EncryptedStreamImage.image(
      image: _makeImage(path),
      type: EncryptedStreamImageType.newImage,
    );

void main() {
  late _MockGalleryReaderUsecase mockGalleryReader;
  late _MockImageDeleterUsecase mockImageDeleter;
  late _MockImageSaverUsecase mockImageSaver;
  late _MockAppBloc mockAppBloc;
  late _MockGalleryBloc mockGalleryBloc;

  setUpAll(() {
    registerFallbackValue(_makeImage('fallback/img.png'));
    registerFallbackValue(
      AppEvent.addEncryptedImage(image: _makeImage('fallback/img.png')),
    );
    registerFallbackValue(ImageDeleterParams(images: []));
    registerFallbackValue(AppEvent.removeEncryptedImage(path: 'fallback'));
    registerFallbackValue(GalleryEvent.decryptImages(image: [], password: ''));
  });

  setUp(() {
    mockGalleryReader = _MockGalleryReaderUsecase();
    mockImageDeleter = _MockImageDeleterUsecase();
    mockImageSaver = _MockImageSaverUsecase();
    mockAppBloc = _MockAppBloc();
    mockGalleryBloc = _MockGalleryBloc();

    when(() => mockAppBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockAppBloc.encryptedImages).thenReturn([]);
    when(() => mockAppBloc.add(any())).thenReturn(null);
    when(() => mockGalleryBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockGalleryBloc.add(any())).thenReturn(null);
  });

  ArchivePageBloc _makeBloc() => ArchivePageBloc(
    appBloc: mockAppBloc,
    galleryBloc: mockGalleryBloc,
    galleryReaderUsecase: mockGalleryReader,
    imageDeleterUsecase: mockImageDeleter,
    imageSaverUseCase: mockImageSaver,
  );

  test('initial state is ArchivePageState.initial', () {
    when(
      () => mockGalleryReader.call(null),
    ).thenAnswer((_) => const Stream.empty());

    final bloc = _makeBloc();
    expect(bloc.state, const ArchivePageState.initial());
    bloc.close();
  });

  // ---------------------------------------------------------------------------
  // setup
  // ---------------------------------------------------------------------------
  group('ArchivePageEvent.setup', () {
    blocTest<ArchivePageBloc, ArchivePageState>(
      'emits [loading, ui] with images from gallery reader',
      build: () {
        when(() => mockGalleryReader.call(null)).thenAnswer(
          (_) => Stream.fromIterable([
            Right(_makeStreamImage('/enc/img1.png')),
            Right(_makeStreamImage('/enc/img2.png')),
          ]),
        );
        return _makeBloc();
      },
      act: (b) => b.add(const ArchivePageEvent.setup()),
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(ui: (u) => u.images.length, orElse: () => -1),
              'images.length',
              2,
            ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'emits [loading, failure] when gallery reader yields Left',
      build: () {
        when(() => mockGalleryReader.call(null)).thenAnswer(
          (_) => Stream.fromIterable([
            Left(DecryptionFailure.decryptionError('read failed')),
          ]),
        );
        return _makeBloc();
      },
      act: (b) => b.add(const ArchivePageEvent.setup()),
      expect:
          () => [
            const ArchivePageState.loading(),
            const ArchivePageState.failure(
              message: 'Decryption error: read failed',
            ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'emits [loading, ui(empty)] when gallery is empty',
      build: () {
        when(
          () => mockGalleryReader.call(null),
        ).thenAnswer((_) => const Stream.empty());
        return _makeBloc();
      },
      act: (b) => b.add(const ArchivePageEvent.setup()),
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(ui: (u) => u.images.length, orElse: () => -1),
              'images.length',
              0,
            ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'adds each image to appBloc via AppEvent.addEncryptedImage',
      build: () {
        when(() => mockGalleryReader.call(null)).thenAnswer(
          (_) =>
              Stream.fromIterable([Right(_makeStreamImage('/enc/img1.png'))]),
        );
        return _makeBloc();
      },
      act: (b) => b.add(const ArchivePageEvent.setup()),
      verify: (_) {
        verify(() => mockAppBloc.add(any())).called(greaterThanOrEqualTo(1));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // delete
  // ---------------------------------------------------------------------------
  group('ArchivePageEvent.delete', () {
    blocTest<ArchivePageBloc, ArchivePageState>(
      'emits [deleting] immediately then removes via appBloc on success',
      build: () {
        when(
          () => mockGalleryReader.call(null),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => mockImageDeleter.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return _makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(ArchivePageEvent.delete(images: [_makeImage('/enc/img1.png')]));
      },
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(ui: (_) => true, orElse: () => false),
              'is ui',
              true,
            ),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(deleting: (d) => d.paths, orElse: () => null),
              'deleting paths',
              contains('/enc/img1.png'),
            ),
          ],
      verify: (_) {
        verify(() => mockAppBloc.add(any())).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'emits failure when deleter returns Left',
      build: () {
        when(
          () => mockGalleryReader.call(null),
        ).thenAnswer((_) => const Stream.empty());
        when(() => mockImageDeleter.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('cannot delete')),
        );
        return _makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        b.add(ArchivePageEvent.delete(images: [_makeImage('/enc/img.png')]));
      },
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(ui: (_) => true, orElse: () => false),
              'is ui',
              true,
            ),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(deleting: (_) => true, orElse: () => false),
              'is deleting',
              true,
            ),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(failure: (f) => f.message, orElse: () => null),
              'failure message',
              contains('cannot delete'),
            ),
          ],
    );
  });
}
