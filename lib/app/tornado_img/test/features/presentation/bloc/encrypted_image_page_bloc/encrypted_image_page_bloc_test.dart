import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/injection_container.dart';

class _MockAppBloc extends Mock implements AppBloc {}

class _MockGalleryBloc extends Mock implements GalleryBloc {}

class _MockImageSaverUsecase extends Mock implements ImageSaverUseCase {}

class _MockImageRenamerUsecase extends Mock implements ImageRenamerUseCase {}

EncryptedImage _makeImage(String path) => EncryptedImage(
  storagePath: StoragePath(
    path: path,
    isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

void main() {
  late _MockAppBloc mockAppBloc;
  late _MockGalleryBloc mockGalleryBloc;
  late _MockImageSaverUsecase mockImageSaverUsecase;
  late _MockImageRenamerUsecase mockImageRenamerUsecase;
  late EncryptedImage tImage;

  setUpAll(() {
    registerFallbackValue(_makeImage('fallback/img.png'));
    registerFallbackValue(
      GalleryEvent.decryptImages(
        image: [_makeImage('fallback/img.png')],
        password: 'fallback',
      ),
    );
    registerFallbackValue(
      AppEvent.addEncryptedImage(image: _makeImage('fallback/img.png')),
    );
    registerFallbackValue(
      ImageRenamerParams(path: '', oldFileName: '', newFileName: ''),
    );
    registerFallbackValue(
      ImageSaverParams.gallery(bytes: Uint8List(0), fileName: 'fallback.png'),
    );
  });

  setUp(() {
    mockAppBloc = _MockAppBloc();
    mockGalleryBloc = _MockGalleryBloc();
    tImage = _makeImage('path/img1.png');
    mockImageSaverUsecase = _MockImageSaverUsecase();
    mockImageRenamerUsecase = _MockImageRenamerUsecase();

    when(() => mockAppBloc.encryptedImages).thenReturn([tImage]);
    when(() => mockAppBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockGalleryBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockGalleryBloc.add(any())).thenReturn(null);
  });

  tearDown(() {
    getIt.reset();
  });

  test('initial state is EncryptedImagePageState.initial', () {
    final bloc = EncryptedImagePageBloc(
      appBloc: mockAppBloc,
      galleryBloc: mockGalleryBloc,
      imageSaverUseCase: mockImageSaverUsecase,
      imageRenamerUseCase: mockImageRenamerUsecase,
    );
    expect(bloc.state, const EncryptedImagePageState.initial());
    bloc.close();
  });

  // ---------------------------------------------------------------------------
  // setup
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.setup', () {
    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits [ui] with correct image on success',
      build:
          () => EncryptedImagePageBloc(
            appBloc: mockAppBloc,
            galleryBloc: mockGalleryBloc,
            imageSaverUseCase: mockImageSaverUsecase,
            imageRenamerUseCase: mockImageRenamerUsecase,
          ),
      act:
          (b) {
        b.add(
          EncryptedImagePageEvent.setup(
            imagePath: tImage.storagePath.file.path,
          ),
        );
      },
      expect:
          () => [
            EncryptedImagePageState.ui(image: tImage),
          ],
      verify: (b) {
        expect(b.image, equals(tImage));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // updatePassword
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.updatePassword', () {
    test('updates password property', () async {
      final bloc = EncryptedImagePageBloc(
        appBloc: mockAppBloc,
        galleryBloc: mockGalleryBloc,
        imageSaverUseCase: mockImageSaverUsecase,
        imageRenamerUseCase: mockImageRenamerUsecase,
      );
      const testPassword = 'test123';

      bloc.add(EncryptedImagePageEvent.updatePassword(testPassword));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.password, equals(testPassword));
      bloc.close();
    });
  });

  // ---------------------------------------------------------------------------
  // restore
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.restore', () {
    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'clears decryptInfo and emits ui with null decryptInfo',
      build: () {
        when(() => mockAppBloc.add(any())).thenReturn(null);
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage.copyWith(
          decryptInfo: BytesInfo(
            bytes: Uint8List.fromList([1, 2, 3]),
            hash: 'h',
          ),
        );
        b.add(const EncryptedImagePageEvent.restore());
      },
      expect:
          () => [
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(ui: (u) => u.image.decryptInfo, orElse: () => 'not_ui'),
              'decryptInfo cleared',
              isNull,
            ),
          ],
      verify: (_) {
        verify(() => mockAppBloc.add(any())).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // decrypt
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.decrypt', () {
    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits [loading, failure] when password is empty',
      build:
          () => EncryptedImagePageBloc(
            appBloc: mockAppBloc,
            galleryBloc: mockGalleryBloc,
            imageSaverUseCase: mockImageSaverUsecase,
            imageRenamerUseCase: mockImageRenamerUsecase,
          ),
      seed: () => EncryptedImagePageState.ui(image: tImage),
      act: (b) => b.add(const EncryptedImagePageEvent.decrypt()),
      expect:
          () => const [
            EncryptedImagePageState.loading(),
            EncryptedImagePageState.failure(
              message: 'Password cannot be empty',
            ),
          ],
    );

    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'calls galleryBloc.add when password is not empty',
      build: () {
        when(() => mockGalleryBloc.add(any())).thenReturn(null);
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      seed: () => EncryptedImagePageState.ui(image: tImage),
      act: (b) {
        b.password = 'test123';
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.decrypt());
      },
      verify: (_) {
        verify(
          () => mockGalleryBloc.add(
            GalleryEvent.decryptImages(image: [tImage], password: 'test123'),
          ),
        ).called(1);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // saveImage
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.saveImage', () {
    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'uses decryptInfo bytes when available and emits imageSaved',
      build: () {
        when(
          () => mockImageSaverUsecase.call(any()),
        ).thenAnswer((_) async => const Right(null));
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        final decryptedBytes = Uint8List.fromList([10, 20, 30]);
        b.image = tImage.copyWith(
          decryptInfo: BytesInfo(bytes: decryptedBytes, hash: 'dh'),
        );
        b.add(const EncryptedImagePageEvent.saveImage());
      },
      verify: (_) {
        final captured =
            verify(() => mockImageSaverUsecase.call(captureAny())).captured;
        final params = captured.first as ImageSaverParams;
        expect(params.bytes, Uint8List.fromList([10, 20, 30]));
      },
      expect:
          () => [
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(imageSaved: (s) => s.path, orElse: () => null),
              'imageSaved emitted',
              isNotNull,
            ),
          ],
    );

    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'falls back to encryptedInfo bytes when decryptInfo is null',
      build: () {
        when(
          () => mockImageSaverUsecase.call(any()),
        ).thenAnswer((_) async => const Right(null));
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.saveImage());
      },
      verify: (_) {
        final captured =
            verify(() => mockImageSaverUsecase.call(captureAny())).captured;
        final params = captured.first as ImageSaverParams;
        expect(params.bytes, tImage.encryptedInfo.bytes);
      },
      expect:
          () => [
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(imageSaved: (s) => s.path, orElse: () => null),
              'imageSaved emitted',
              isNotNull,
            ),
          ],
    );

    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits failure when saver returns Left',
      build: () {
        when(() => mockImageSaverUsecase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('disk full')),
        );
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.saveImage());
      },
      expect:
          () => [
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(failure: (f) => f.message, orElse: () => null),
              'failure message',
              contains('disk full'),
            ),
          ],
    );
  });

  // ---------------------------------------------------------------------------
  // rename
  // ---------------------------------------------------------------------------
  group('EncryptedImagePageEvent.rename', () {
    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits [loading, imageRenamed, ui(newPath)] on success',
      build: () {
        when(() => mockAppBloc.add(any())).thenReturn(null);
        when(() => mockImageRenamerUsecase.call(any())).thenAnswer(
          (_) async =>
              const Right(StorageRenameResult(success: true, newAssetId: null)),
        );
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.rename(newName: 'newname'));
      },
      expect:
          () => [
            const EncryptedImagePageState.loading(),
            const EncryptedImagePageState.imageRenamed(),
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(
                ui: (u) => u.image.storagePath.path,
                orElse: () => null,
              ),
              'new path',
              equals('path/newname.png'),
            ),
          ],
      verify: (_) {
        verify(() => mockAppBloc.add(any())).called(1);
      },
    );

    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits [loading, failure] when renamer returns Left',
      build: () {
        when(() => mockImageRenamerUsecase.call(any())).thenAnswer(
          (_) async =>
              Left(EncryptionFailure.encryptionError('rename failed')),
        );
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.rename(newName: 'newname'));
      },
      expect:
          () => [
            const EncryptedImagePageState.loading(),
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(failure: (f) => f.message, orElse: () => null),
              'failure message',
              contains('rename failed'),
            ),
          ],
    );

    blocTest<EncryptedImagePageBloc, EncryptedImagePageState>(
      'emits [loading, failure] when rename result success is false',
      build: () {
        when(() => mockImageRenamerUsecase.call(any())).thenAnswer(
          (_) async =>
              const Right(StorageRenameResult(success: false, newAssetId: null)),
        );
        return EncryptedImagePageBloc(
          appBloc: mockAppBloc,
          galleryBloc: mockGalleryBloc,
          imageSaverUseCase: mockImageSaverUsecase,
          imageRenamerUseCase: mockImageRenamerUsecase,
        );
      },
      act: (b) {
        b.image = tImage;
        b.add(const EncryptedImagePageEvent.rename(newName: 'newname'));
      },
      expect:
          () => [
            const EncryptedImagePageState.loading(),
            isA<EncryptedImagePageState>().having(
              (s) => s.maybeMap(failure: (f) => f.message, orElse: () => null),
              'failure message',
              isNotNull,
            ),
          ],
    );
  });
}
