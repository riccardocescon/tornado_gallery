import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_video_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';

class _MockEncryptImageUseCase extends Mock implements EncryptImageUseCase {}

class _MockEncryptVideoUseCase extends Mock implements EncryptVideoUseCase {}

class _MockDecryptImageUseCase extends Mock implements DecryptImageUseCase {}

const _tDestination = '/path';
const _tImageId = 'img1';

Future<Uint8List?> _tPosterFetcher(String assetId) async =>
    Uint8List.fromList([1, 2, 3]);

GalleryBloc _makeBloc({
  required _MockEncryptImageUseCase encrypt,
  required _MockDecryptImageUseCase decrypt,
  _MockEncryptVideoUseCase? encryptVideo,
  List<EncryptedImage> existingEncryptedImages = const [],
  VideoPosterFetcher fetchVideoPoster = _tPosterFetcher,
}) {
  final appBloc = AppBloc();
  appBloc.encryptedImages.addAll(existingEncryptedImages);
  final getIt = GetIt.asNewInstance();
  getIt.registerSingleton<AppBloc>(appBloc);
  return GalleryBloc(
    encryptUseCase: encrypt,
    encryptVideoUseCase: encryptVideo ?? _MockEncryptVideoUseCase(),
    decryptUseCase: decrypt,
    appBloc: appBloc,
    fetchVideoPoster: fetchVideoPoster,
  );
}

void main() {
  late _MockEncryptImageUseCase mockEncryptionUseCase;
  late _MockDecryptImageUseCase mockDecryptUseCase;
  late GalleryImage tImage;
  late EncryptedImage tEncryptedImage;

  final tFile = File('test_image.png');

  setUpAll(() {
    registerFallbackValue(
      EncryptImageParams(
        file: tFile,
        password: 'pw',
        fileId: _tImageId,
        settings: EncryptionSettings.init().copyWith(
          outputFolder: _tDestination,
        ),
      ),
    );
    registerFallbackValue(DecryptImageParams(file: tFile, password: ''));
    registerFallbackValue(
      EncryptVideoParams(
        file: tFile,
        password: 'pw',
        fileId: _tImageId,
        posterBytes: Uint8List(0),
      ),
    );
  });

  setUp(() {
    mockEncryptionUseCase = _MockEncryptImageUseCase();
    mockDecryptUseCase = _MockDecryptImageUseCase();
    tImage = GalleryImage(id: _tImageId, file: tFile, date: DateTime(2024));
    tEncryptedImage = EncryptedImage(
      storagePath: StoragePath(
        path: 'encrypted_img1.enc',
        isPrivateFolder: false,
        assetId: null,
      ),
      encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
      date: DateTime(2024),
    );
  });

  test('initial state is GalleryState.initial', () {
    final bloc = _makeBloc(
      encrypt: mockEncryptionUseCase,
      decrypt: mockDecryptUseCase,
    );
    expect(bloc.state, const GalleryState.initial());
    bloc.close();
  });

  group('GalleryEvent.encryptImages', () {
    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encrypted] when use case succeeds',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [tEncryptedImage],
                failedImages: [],
                skippedImages: [],
              ),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encrypted with failedImages] when use case returns Left',
      build: () {
        when(() => mockEncryptionUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('bad')),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      expect:
          () => [
            const GalleryState.loadingEncryption(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.failedImages,
                orElse: () => null,
              ),
              'failedImages',
              contains(tImage),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, encrypted with failedImages] for unsupported extension',
      build: () {
        when(() => mockEncryptionUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.unsupportedExtension('bmp')),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: '/folder',
              ),
            ),
          ),
      expect:
          () => [
            const GalleryState.loadingEncryption(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.failedImages,
                orElse: () => null,
              ),
              'failedImages',
              contains(tImage),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'passes correct params to use case',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'mypassword',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: '/my/path',
              ),
            ),
          ),
      verify: (_) {
        final captured =
            verify(() => mockEncryptionUseCase.call(captureAny())).captured;
        final params = captured.first as EncryptImageParams;
        expect(params.file, tFile);
        expect(params.password, 'mypassword');
        expect(params.fileId, _tImageId);
        expect(params.settings.outputFolder, '/my/path');
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits progress state after each image in a multi-image batch',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act: (b) {
        final image2 = GalleryImage(
          id: 'img2',
          file: tFile,
          date: DateTime(2024),
        );
        b.add(
          GalleryEvent.encryptImages(
            images: {tImage: null, image2: null},
            password: 'secret',
            settings: EncryptionSettings.init().copyWith(
              outputFolder: _tDestination,
            ),
          ),
        );
      },
      expect:
          () => [
            GalleryState.loadingEncryption(total: 2),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.archivedImages.length,
                orElse: () => 0,
              ),
              'archivedImages.length after first image',
              equals(1),
            ),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.archivedImages.length,
                orElse: () => 0,
              ),
              'archivedImages.length after second image',
              equals(2),
            ),
          ],
    );
  });

  group('Video routing', () {
    late GalleryImage tVideoImage;
    late _MockEncryptVideoUseCase mockEncryptVideoUseCase;
    late EncryptedImage tEncryptedVideo;

    setUp(() {
      mockEncryptVideoUseCase = _MockEncryptVideoUseCase();
      tVideoImage = GalleryImage(
        id: 'vid1',
        file: File('clip.mp4'),
        date: DateTime(2024),
      );
      tEncryptedVideo = EncryptedImage(
        storagePath: StoragePath(
          path: 'encrypted_vid1.mp4',
          isPrivateFolder: true,
          assetId: null,
        ),
        encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
        date: DateTime(2024),
      );
    });

    blocTest<GalleryBloc, GalleryState>(
      'routes a video asset (.mp4) to EncryptVideoUseCase, not EncryptImageUseCase',
      build: () {
        when(
          () => mockEncryptVideoUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedVideo));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tVideoImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [tEncryptedVideo],
                failedImages: [],
                skippedImages: [],
              ),
            ),
          ],
      verify: (_) {
        verify(() => mockEncryptVideoUseCase.call(any())).called(1);
        verifyNever(() => mockEncryptionUseCase.call(any()));
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'routes a non-video asset to EncryptImageUseCase, not EncryptVideoUseCase',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      verify: (_) {
        verify(() => mockEncryptionUseCase.call(any())).called(1);
        verifyNever(() => mockEncryptVideoUseCase.call(any()));
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'fetches the poster thumbnail and passes it plus correct params to EncryptVideoUseCase',
      build: () {
        when(
          () => mockEncryptVideoUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedVideo));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
          fetchVideoPoster: _tPosterFetcher,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tVideoImage: 'my_video'},
              password: 'mypassword',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: '/my/videos',
              ),
            ),
          ),
      verify: (_) async {
        final captured =
            verify(() => mockEncryptVideoUseCase.call(captureAny())).captured;
        final params = captured.first as EncryptVideoParams;
        expect(params.file, tVideoImage.file);
        expect(params.password, 'mypassword');
        expect(params.fileId, 'my_video');
        expect(params.posterBytes, await _tPosterFetcher('vid1'));
        expect(params.destinationPath, '/my/videos');
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'marks the video failed without calling EncryptVideoUseCase when the poster thumbnail is null',
      build: () {
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
          fetchVideoPoster: (_) async => null,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tVideoImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.failedImages,
                orElse: () => null,
              ),
              'failedImages',
              contains(tVideoImage),
            ),
          ],
      verify: (_) => verifyNever(() => mockEncryptVideoUseCase.call(any())),
    );

    blocTest<GalleryBloc, GalleryState>(
      'surfaces a distinct, actionable message for an oversize video (fileTooLarge)',
      build: () {
        when(() => mockEncryptVideoUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.fileTooLarge(3000000000, 2147483648)),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tVideoImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      verify: (_) {
        final failureLog =
            appLogger.allLogs.last;
        expect(failureLog.error, contains('too large'));
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'surfaces a distinct message (not the oversize one) for a generic video encryption error',
      build: () {
        when(() => mockEncryptVideoUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('native cipher crashed')),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          encryptVideo: mockEncryptVideoUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tVideoImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
              ),
            ),
          ),
      verify: (_) {
        final failureLog = appLogger.allLogs.last;
        expect(failureLog.error, contains('native cipher crashed'));
        expect(failureLog.error, isNot(contains('too large')));
      },
    );
  });

  group('Skipping logic', () {
    blocTest<GalleryBloc, GalleryState>(
      'skips image when overrideImage is false and image exists at destination',
      build: () {
        final existingImage = EncryptedImage(
          storagePath: StoragePath(
            path: '$_tDestination/$_tImageId.png',
            isPrivateFolder: false,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
          date: DateTime(2024),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          existingEncryptedImages: [existingImage],
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
                overrideImage: false,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [],
                failedImages: [],
                skippedImages: [tImage],
              ),
            ),
          ],
      verify: (_) => verifyNever(() => mockEncryptionUseCase.call(any())),
    );

    blocTest<GalleryBloc, GalleryState>(
      'skips a video when overrideImage is false and a .mp4 already exists at destination',
      build: () {
        final existingVideo = EncryptedImage(
          storagePath: StoragePath(
            path: '$_tDestination/vid1.mp4',
            isPrivateFolder: true,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
          date: DateTime(2024),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          existingEncryptedImages: [existingVideo],
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {
                GalleryImage(id: 'vid1', file: File('clip.mp4'), date: DateTime(2024)):
                    null,
              },
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
                overrideImage: false,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.skippedImages,
                orElse: () => null,
              ),
              'skippedImages',
              hasLength(1),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'does not skip image when overrideImage is true even if image exists at destination',
      build: () {
        final existingImage = EncryptedImage(
          storagePath: StoragePath(
            path: '$_tDestination/$_tImageId.png',
            isPrivateFolder: false,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
          date: DateTime(2024),
        );
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          existingEncryptedImages: [existingImage],
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
                overrideImage: true,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [tEncryptedImage],
                failedImages: [],
                skippedImages: [],
              ),
            ),
          ],
      verify: (_) => verify(() => mockEncryptionUseCase.call(any())).called(1),
    );

    blocTest<GalleryBloc, GalleryState>(
      'does not skip image when overrideImage is false and image does not exist at destination',
      build: () {
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.encryptImages(
              images: {tImage: null},
              password: 'secret',
              settings: EncryptionSettings.init().copyWith(
                outputFolder: _tDestination,
                overrideImage: false,
              ),
            ),
          ),
      expect:
          () => [
            GalleryState.loadingEncryption(total: 1),
            GalleryState.encrypted(
              archivingState: ArchivingState(
                totalImages: 1,
                archivedImages: [tEncryptedImage],
                failedImages: [],
                skippedImages: [],
              ),
            ),
          ],
      verify: (_) => verify(() => mockEncryptionUseCase.call(any())).called(1),
    );

    blocTest<GalleryBloc, GalleryState>(
      'skips existing and encrypts new in mixed batch',
      build: () {
        final existingImage = EncryptedImage(
          storagePath: StoragePath(
            path: '$_tDestination/$_tImageId.png',
            isPrivateFolder: false,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
          date: DateTime(2024),
        );
        when(
          () => mockEncryptionUseCase.call(any()),
        ).thenAnswer((_) async => Right(tEncryptedImage));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
          existingEncryptedImages: [existingImage],
        );
      },
      act: (b) {
        final image2 = GalleryImage(
          id: 'img2',
          file: tFile,
          date: DateTime(2024),
        );
        b.add(
          GalleryEvent.encryptImages(
            images: {tImage: null, image2: null},
            password: 'secret',
            settings: EncryptionSettings.init().copyWith(
              outputFolder: _tDestination,
              overrideImage: false,
            ),
          ),
        );
      },
      expect:
          () => [
            GalleryState.loadingEncryption(total: 2),
            // After tImage (skipped — exists at destination)
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted: (e) => e.archivingState.skippedImages,
                orElse: () => null,
              ),
              'skippedImages contains tImage',
              contains(tImage),
            ),
            // After image2 (encrypted — does not exist at destination)
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                encrypted:
                    (e) =>
                        e.archivingState.skippedImages.length == 1 &&
                        e.archivingState.archivedImages.length == 1,
                orElse: () => false,
              ),
              'skipped=1 archived=1 in final state',
              isTrue,
            ),
          ],
      verify: (_) => verify(() => mockEncryptionUseCase.call(any())).called(1),
    );
  });

  group('GalleryEvent.decryptImages', () {
    final tDecryptedInfo = BytesInfo(
      bytes: Uint8List.fromList([5, 6, 7]),
      hash: 'decrypted_hash',
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loadingDecryption, decrypted(initial), decrypted(success)] on success',
      build: () {
        when(
          () => mockDecryptUseCase.call(any()),
        ).thenAnswer((_) async => Right(tDecryptedInfo));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.decryptImages(
              image: [tEncryptedImage],
              password: 'secret',
            ),
          ),
      expect:
          () => [
            GalleryState.loadingDecryption(total: 1),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.dearchivingState.loadingImages,
                orElse: () => null,
              ),
              'initial: image in loadingImages',
              hasLength(1),
            ),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.dearchivingState.dearchivedImages,
                orElse: () => null,
              ),
              'final: image moved to dearchived',
              hasLength(1),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits decrypted with failedImages when use case returns Left',
      build: () {
        when(() => mockDecryptUseCase.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('bad key')),
        );
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.decryptImages(
              image: [tEncryptedImage],
              password: 'wrong',
            ),
          ),
      expect:
          () => [
            GalleryState.loadingDecryption(total: 1),
            isA<GalleryState>(),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.dearchivingState.failedImages,
                orElse: () => null,
              ),
              'image in failedImages',
              contains(tEncryptedImage),
            ),
          ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'passes correct file and password to decryptUseCase',
      build: () {
        when(
          () => mockDecryptUseCase.call(any()),
        ).thenAnswer((_) async => Right(tDecryptedInfo));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act:
          (b) => b.add(
            GalleryEvent.decryptImages(
              image: [tEncryptedImage],
              password: 'mypass',
            ),
          ),
      verify: (_) {
        final captured =
            verify(() => mockDecryptUseCase.call(captureAny())).captured;
        final params = captured.first as DecryptImageParams;
        expect(params.file.path, tEncryptedImage.storagePath.file.path);
        expect(params.password, 'mypass');
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits progress states for each image in multi-image batch',
      build: () {
        when(
          () => mockDecryptUseCase.call(any()),
        ).thenAnswer((_) async => Right(tDecryptedInfo));
        return _makeBloc(
          encrypt: mockEncryptionUseCase,
          decrypt: mockDecryptUseCase,
        );
      },
      act: (b) {
        final image2 = EncryptedImage(
          storagePath: StoragePath(
            path: 'enc2.png',
            isPrivateFolder: true,
            assetId: null,
          ),
          encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
          date: DateTime(2024),
        );
        b.add(
          GalleryEvent.decryptImages(
            image: [tEncryptedImage, image2],
            password: 'secret',
          ),
        );
      },
      expect:
          () => [
            GalleryState.loadingDecryption(total: 2),
            isA<GalleryState>(),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.dearchivingState.dearchivedImages.length,
                orElse: () => 0,
              ),
              'one dearchived after first image',
              equals(1),
            ),
            isA<GalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.dearchivingState.dearchivedImages.length,
                orElse: () => 0,
              ),
              'two dearchived after second image',
              equals(2),
            ),
          ],
    );
  });
}
