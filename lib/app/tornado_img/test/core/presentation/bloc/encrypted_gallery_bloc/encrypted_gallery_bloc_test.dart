import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/repositories/encrypted_gallery_repository.dart';
import 'package:tornado_img_app/core/failues/failures.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';

class _MockEncryptedGalleryRepository extends Mock
    implements EncryptedGalleryRepository {}

EncryptedImage _makeImage(String id) =>
    EncryptedImage(id: id, file: File('path/$id.png'), date: DateTime(2024));

void main() {
  late _MockEncryptedGalleryRepository mockRepository;
  late EncryptedImage tImage;

  final tBytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(_makeImage('fallback'));
    registerFallbackValue(<EncryptedImage>[]);
    registerFallbackValue(Directory('/tmp'));
  });

  setUp(() {
    mockRepository = _MockEncryptedGalleryRepository();
    tImage = _makeImage('img1');
  });

  test('initial state is EncryptedGalleryState.initial', () {
    final bloc = EncryptedGalleryBloc(mockRepository);
    expect(bloc.state, const EncryptedGalleryState.initial());
    bloc.close();
  });

  // ---------------------------------------------------------------------------
  // decryptImage
  // ---------------------------------------------------------------------------
  group('EncryptedGalleryEvent.decryptImage', () {
    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, decrypted] on success',
      build: () {
        when(
          () => mockRepository.decryptImage(
            image: any(named: 'image'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(tBytes));
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
          ),
      expect:
          () => [
            const EncryptedGalleryState.loading(),
            isA<EncryptedGalleryState>().having(
              (s) => s.maybeMap(
                decrypted: (d) => d.data.decryptedBytes,
                orElse: () => null,
              ),
              'data.decryptedBytes',
              tBytes,
            ),
          ],
      verify: (b) {
        expect(b.images.length, 1);
        expect(b.images.first.decryptedBytes, tBytes);
        expect(b.images.first.isDecrypting, false);
      },
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'caches the same image on a second decryptImage call instead of duplicating',
      build: () {
        when(
          () => mockRepository.decryptImage(
            image: any(named: 'image'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(tBytes));
        return EncryptedGalleryBloc(mockRepository);
      },
      act: (b) async {
        b.add(
          EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
        );
        await b.stream.firstWhere(
          (s) => s.maybeMap(decrypted: (_) => true, orElse: () => false),
        );
        b.add(
          EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
        );
      },
      verify: (b) => expect(b.images.length, 1),
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, encryptionFailure] on failure',
      build: () {
        when(
          () => mockRepository.decryptImage(
            image: any(named: 'image'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async =>
              Left(EncryptionFailure.encryptionError('decrypt failed')),
        );
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
          ),
      expect:
          () => [
            const EncryptedGalleryState.loading(),
            isA<EncryptedGalleryState>().having(
              (s) => s.maybeMap(
                encryptionFailure: (f) => f.failure.message,
                orElse: () => '',
              ),
              'failure.message',
              contains('decrypt failed'),
            ),
          ],
    );
  });

  // ---------------------------------------------------------------------------
  // decryptFolder
  // ---------------------------------------------------------------------------
  group('EncryptedGalleryEvent.decryptFolder', () {
    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, decryptedFolderCompleted] on success',
      build: () {
        when(
          () => mockRepository.decryptFolder(
            images: any(named: 'images'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => const Right([]));
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            EncryptedGalleryEvent.decryptFolder(
              images: [tImage],
              password: 'pw',
            ),
          ),
      expect:
          () => const [
            EncryptedGalleryState.loading(),
            EncryptedGalleryState.decryptedFolderCompleted(),
          ],
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'sets isDecrypting = true on each image before passing to repository',
      build: () {
        when(
          () => mockRepository.decryptFolder(
            images: any(named: 'images'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {
          // By the time the repo is called, isDecrypting must already be true.
          expect(tImage.isDecrypting, isTrue);
          return const Right([]);
        });
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            EncryptedGalleryEvent.decryptFolder(
              images: [tImage],
              password: 'pw',
            ),
          ),
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, encryptionFailure] on failure',
      build: () {
        when(
          () => mockRepository.decryptFolder(
            images: any(named: 'images'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('folder failed')),
        );
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            EncryptedGalleryEvent.decryptFolder(
              images: [tImage],
              password: 'pw',
            ),
          ),
      expect:
          () => [
            const EncryptedGalleryState.loading(),
            isA<EncryptedGalleryState>().having(
              (s) => s.maybeMap(
                encryptionFailure: (f) => f.failure.message,
                orElse: () => '',
              ),
              'failure.message',
              contains('folder failed'),
            ),
          ],
    );
  });

  // ---------------------------------------------------------------------------
  // deleteFolderGlobal
  // ---------------------------------------------------------------------------
  group('EncryptedGalleryEvent.deleteFolderGlobal', () {
    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, folderDeleted] with correct folderPath on success',
      build: () {
        when(
          () => mockRepository.deleteFolder(any()),
        ).thenAnswer((_) async => const Right(null));
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            const EncryptedGalleryEvent.deleteFolderGlobal(
              folderName: 'summer',
            ),
          ),
      expect:
          () => const [
            EncryptedGalleryState.loading(),
            EncryptedGalleryState.folderDeleted(folderPath: 'summer'),
          ],
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'passes the folder name to the repository',
      build: () {
        when(
          () => mockRepository.deleteFolder(any()),
        ).thenAnswer((_) async => const Right(null));
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            const EncryptedGalleryEvent.deleteFolderGlobal(
              folderName: 'summer',
            ),
          ),
      verify: (_) {
        verify(() => mockRepository.deleteFolder('summer')).called(1);
      },
    );

    blocTest<EncryptedGalleryBloc, EncryptedGalleryState>(
      'emits [loading, encryptionFailure] on failure',
      build: () {
        when(() => mockRepository.deleteFolder(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('delete error')),
        );
        return EncryptedGalleryBloc(mockRepository);
      },
      act:
          (b) => b.add(
            const EncryptedGalleryEvent.deleteFolderGlobal(
              folderName: 'summer',
            ),
          ),
      expect:
          () => [
            const EncryptedGalleryState.loading(),
            isA<EncryptedGalleryState>().having(
              (s) => s.maybeMap(
                encryptionFailure: (f) => f.failure.message,
                orElse: () => '',
              ),
              'failure.message',
              contains('delete error'),
            ),
          ],
    );
  });

  // ---------------------------------------------------------------------------
  // clearDecryptedData
  // ---------------------------------------------------------------------------
  group('clearDecryptedData', () {
    test(
      'sets decryptedBytes to null and isDecrypting to false for all cached images',
      () async {
        when(
          () => mockRepository.decryptImage(
            image: any(named: 'image'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(tBytes));

        final bloc = EncryptedGalleryBloc(mockRepository);
        bloc.add(
          EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
        );
        await bloc.stream.firstWhere(
          (s) => s.maybeMap(decrypted: (_) => true, orElse: () => false),
        );

        expect(bloc.images.first.decryptedBytes, isNotNull);

        bloc.clearDecryptedData();

        expect(bloc.images.first.decryptedBytes, isNull);
        expect(bloc.images.first.isDecrypting, false);
        await bloc.close();
      },
    );
  });

  // ---------------------------------------------------------------------------
  // removeImage
  // ---------------------------------------------------------------------------
  group('removeImage', () {
    test('removes the image from the internal cache by file path', () async {
      when(
        () => mockRepository.decryptImage(
          image: any(named: 'image'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(tBytes));

      final bloc = EncryptedGalleryBloc(mockRepository);
      bloc.add(
        EncryptedGalleryEvent.decryptImage(image: tImage, password: 'pw'),
      );
      await bloc.stream.firstWhere(
        (s) => s.maybeMap(decrypted: (_) => true, orElse: () => false),
      );

      expect(bloc.images.length, 1);

      bloc.removeImage(tImage.file.path);

      expect(bloc.images.length, 0);
      await bloc.close();
    });

    test('does nothing when image is not in cache', () {
      final bloc = EncryptedGalleryBloc(mockRepository);
      bloc.removeImage('nonexistent/path.png');
      expect(bloc.images, isEmpty);
      bloc.close();
    });
  });
}
