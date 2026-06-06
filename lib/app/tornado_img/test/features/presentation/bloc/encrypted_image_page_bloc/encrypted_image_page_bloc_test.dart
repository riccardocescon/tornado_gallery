import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/injection_container.dart';

class _MockAppBloc extends Mock implements AppBloc {}

class _MockGalleryBloc extends Mock implements GalleryBloc {}

class _MockImageSaverUsecase extends Mock implements ImageSaverUsecase {}

class _MockImageRenamerUsecase extends Mock implements ImageRenamerUsecase {}

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
      imageSaverUsecase: mockImageSaverUsecase,
      imageRenamerUsecase: mockImageRenamerUsecase,
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
            imageSaverUsecase: mockImageSaverUsecase,
            imageRenamerUsecase: mockImageRenamerUsecase,
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
        imageSaverUsecase: mockImageSaverUsecase,
        imageRenamerUsecase: mockImageRenamerUsecase,
      );
      const testPassword = 'test123';

      bloc.add(EncryptedImagePageEvent.updatePassword(testPassword));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.password, equals(testPassword));
      bloc.close();
    });
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
            imageSaverUsecase: mockImageSaverUsecase,
            imageRenamerUsecase: mockImageRenamerUsecase,
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
          imageSaverUsecase: mockImageSaverUsecase,
          imageRenamerUsecase: mockImageRenamerUsecase,
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
}
