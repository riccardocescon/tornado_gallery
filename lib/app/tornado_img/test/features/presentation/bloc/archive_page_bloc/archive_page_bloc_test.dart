import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/usecases/create_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/delete_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/move_images_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/rename_folder_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/managers/decrypt_job_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';

class _MockGalleryReaderUsecase extends Mock implements GalleryReaderUseCase {}

class _MockImageDeleterUsecase extends Mock implements ImageDeleterUseCase {}

class _MockImageSaverUsecase extends Mock implements ImageSaverUseCase {}

class _MockCreateFolderUsecase extends Mock implements CreateFolderUseCase {}

class _MockRenameFolderUsecase extends Mock implements RenameFolderUseCase {}

class _MockDeleteFolderUsecase extends Mock implements DeleteFolderUseCase {}

class _MockMoveImagesUsecase extends Mock implements MoveImagesUseCase {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockDecryptJobManager extends Mock implements DecryptJobManager {}

class _MockPurchaseBloc extends Mock implements PurchaseBloc {}

EncryptedImage _makeImage(String path, {bool isPrivate = true}) =>
    EncryptedImage(
      storagePath: StoragePath(
        path: path,
        isPrivateFolder: isPrivate,
        assetId: null,
      ),
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
  late _MockCreateFolderUsecase mockCreateFolder;
  late _MockRenameFolderUsecase mockRenameFolder;
  late _MockDeleteFolderUsecase mockDeleteFolder;
  late _MockMoveImagesUsecase mockMoveImages;
  late _MockAppBloc mockAppBloc;
  late _MockDecryptJobManager mockDecryptJobManager;
  late _MockPurchaseBloc mockPurchaseBloc;

  setUpAll(() {
    registerFallbackValue(_makeImage('fallback/img.png'));
    registerFallbackValue(
      AppEvent.addEncryptedImage(image: _makeImage('fallback/img.png')),
    );
    registerFallbackValue(ImageDeleterParams(images: []));
    registerFallbackValue(AppEvent.removeEncryptedImage(path: 'fallback'));
    registerFallbackValue(
      CreateFolderParams(parentRelativePath: '', name: 'x', isPrivate: true),
    );
    registerFallbackValue(
      RenameFolderParams(relativePath: 'x', newName: 'y', isPrivate: true),
    );
    registerFallbackValue(
      DeleteFolderParams(relativePath: 'x', isPrivate: true),
    );
    registerFallbackValue(MoveImagesParams(images: [], targetRelativePath: ''));
  });

  setUp(() {
    mockGalleryReader = _MockGalleryReaderUsecase();
    mockImageDeleter = _MockImageDeleterUsecase();
    mockImageSaver = _MockImageSaverUsecase();
    mockCreateFolder = _MockCreateFolderUsecase();
    mockRenameFolder = _MockRenameFolderUsecase();
    mockDeleteFolder = _MockDeleteFolderUsecase();
    mockMoveImages = _MockMoveImagesUsecase();
    mockAppBloc = _MockAppBloc();
    mockDecryptJobManager = _MockDecryptJobManager();
    mockPurchaseBloc = _MockPurchaseBloc();

    // Pro by default so the existing tests exercise folder behaviour rather
    // than the free-tier cap; the cap tests below opt out explicitly.
    when(() => mockPurchaseBloc.isPro).thenReturn(true);

    when(() => mockAppBloc.stream).thenAnswer((_) => Stream.empty());
    when(() => mockAppBloc.encryptedImages).thenReturn([]);
    when(() => mockAppBloc.add(any())).thenReturn(null);
    when(
      () => mockDecryptJobManager.updates,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockDecryptJobManager.jobState(any())).thenReturn(null);
    when(() => mockDecryptJobManager.isRunning(any())).thenReturn(false);
    when(() => mockDecryptJobManager.cancel(any())).thenReturn(null);
    when(
      () => mockDecryptJobManager.start(
        key: any(named: 'key'),
        images: any(named: 'images'),
        password: any(named: 'password'),
      ),
    ).thenReturn(null);
    when(
      () => mockGalleryReader.readPrivateFolderPaths(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockGalleryReader.readPublicFolderPaths(),
    ).thenAnswer((_) => const Stream.empty());
  });

  ArchivePageBloc makeBloc() => ArchivePageBloc(
    appBloc: mockAppBloc,
    purchaseBloc: mockPurchaseBloc,
    decryptJobManager: mockDecryptJobManager,
    galleryReaderUseCase: mockGalleryReader,
    imageDeleterUseCase: mockImageDeleter,
    imageSaverUseCase: mockImageSaver,
    createFolderUseCase: mockCreateFolder,
    renameFolderUseCase: mockRenameFolder,
    deleteFolderUseCase: mockDeleteFolder,
    moveImagesUseCase: mockMoveImages,
  );

  test('initial state is ArchivePageState.initial', () {
    when(
      () => mockGalleryReader.call(null),
    ).thenAnswer((_) => const Stream.empty());

    final bloc = makeBloc();
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
        return makeBloc();
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
        return makeBloc();
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
        return makeBloc();
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
        return makeBloc();
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
        when(
          () => mockAppBloc.encryptedImages,
        ).thenReturn([_makeImage('/enc/img1.png')]);
        return makeBloc();
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
        return makeBloc();
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

  // ---------------------------------------------------------------------------
  // folder navigation
  // ---------------------------------------------------------------------------
  group('folder navigation', () {
    void seedNested() {
      when(() => mockGalleryReader.call(null)).thenAnswer(
        (_) => Stream.fromIterable([
          Right(_makeStreamImage('/app/encrypted/root.png')),
          Right(_makeStreamImage('/app/encrypted/Vacanze/a.png')),
          Right(_makeStreamImage('/app/encrypted/Vacanze/Mare/b.png')),
        ]),
      );
    }

    blocTest<ArchivePageBloc, ArchivePageState>(
      'root level shows top folder Vacanze and only root images',
      build: () {
        seedNested();
        return makeBloc();
      },
      act: (b) => b.add(const ArchivePageEvent.setup()),
      verify: (_) {},
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>()
                .having(
                  (s) => s.maybeMap(
                    ui: (u) => u.folders.map((f) => f.name).toList(),
                    orElse: () => <String>[],
                  ),
                  'folder names',
                  ['Vacanze'],
                )
                .having(
                  (s) =>
                      s.maybeMap(ui: (u) => u.images.length, orElse: () => -1),
                  'root images',
                  1,
                ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'entering Vacanze shows nested folder Mare, its image and breadcrumb',
      build: () {
        seedNested();
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(
          const ArchivePageEvent.enterFolder(
            relativePath: 'Vacanze',
            isPrivate: true,
          ),
        );
      },
      skip: 2,
      expect:
          () => [
            isA<ArchivePageState>()
                .having(
                  (s) => s.maybeMap(
                    ui: (u) => u.breadcrumb,
                    orElse: () => <String>[],
                  ),
                  'breadcrumb',
                  ['Vacanze'],
                )
                .having(
                  (s) => s.maybeMap(
                    ui: (u) => u.folders.map((f) => f.name).toList(),
                    orElse: () => <String>[],
                  ),
                  'subfolders',
                  ['Mare'],
                )
                .having(
                  (s) =>
                      s.maybeMap(ui: (u) => u.images.length, orElse: () => -1),
                  'images in Vacanze',
                  1,
                ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'createFolder is blocked at the free archive cap and offers Pro instead',
      build: () {
        when(() => mockPurchaseBloc.isPro).thenReturn(false);
        // Exactly at the cap already: the next archive must not be created.
        when(() => mockGalleryReader.call(null)).thenAnswer(
          (_) => Stream.fromIterable([
            for (var i = 0; i < Constants.maxArchives; i++)
              Right<DecryptionFailure, EncryptedStreamImage>(
                _makeStreamImage('/app/encrypted/Archive$i/img.png'),
              ),
          ]),
        );
        when(
          () => mockCreateFolder.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(const ArchivePageEvent.createFolder(name: 'OneTooMany'));
      },
      verify: (_) {
        verifyNever(() => mockCreateFolder.call(any()));
      },
      expect:
          () => [
            const ArchivePageState.loading(),
            isA<ArchivePageState>().having(
              (s) => s.maybeMap(ui: (_) => true, orElse: () => false),
              'is ui',
              true,
            ),
            const ArchivePageState.limitReached(),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'createFolder past the free cap is allowed for a Pro user',
      build: () {
        when(() => mockPurchaseBloc.isPro).thenReturn(true);
        when(() => mockGalleryReader.call(null)).thenAnswer(
          (_) => Stream.fromIterable([
            for (var i = 0; i < Constants.maxArchives; i++)
              Right<DecryptionFailure, EncryptedStreamImage>(
                _makeStreamImage('/app/encrypted/Archive$i/img.png'),
              ),
          ]),
        );
        when(
          () => mockCreateFolder.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(const ArchivePageEvent.createFolder(name: 'OneMore'));
      },
      verify: (_) {
        verify(() => mockCreateFolder.call(any())).called(1);
      },
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'createFolder calls usecase and surfaces the new folder',
      build: () {
        when(
          () => mockGalleryReader.call(null),
        ).thenAnswer((_) => const Stream.empty());
        when(
          () => mockCreateFolder.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(const ArchivePageEvent.createFolder(name: 'NewFolder'));
      },
      verify: (_) {
        verify(() => mockCreateFolder.call(any())).called(1);
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
              (s) => s.maybeMap(
                ui: (u) => u.folders.map((f) => f.name).toList(),
                orElse: () => <String>[],
              ),
              'folders include NewFolder',
              contains('NewFolder'),
            ),
          ],
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'renameFolder rewrites in-memory image paths under the renamed folder',
      build: () {
        seedNested();
        when(
          () => mockRenameFolder.call(any()),
        ).thenAnswer((_) async => const Right(true));
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(
          const ArchivePageEvent.renameFolder(
            relativePath: 'Vacanze',
            isPrivate: true,
            newName: 'Holidays',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      },
      verify: (_) {
        final captured = verify(() => mockAppBloc.add(captureAny())).captured;
        final renamedPaths =
            captured
                .whereType<AppEvent>()
                .map(
                  (e) => e.maybeMap(
                    updateEncryptedImage: (v) => v.image.storagePath.path,
                    orElse: () => null,
                  ),
                )
                .whereType<String>()
                .toList();
        expect(
          renamedPaths,
          containsAll(<String>[
            '/app/encrypted/Holidays/a.png',
            '/app/encrypted/Holidays/Mare/b.png',
          ]),
        );
      },
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'deleteFolder removes the folder optimistically before the delete '
      'usecase resolves',
      build: () {
        seedNested();
        // Slow delete: the folder must already be gone from the emitted ui
        // before this completes.
        when(() => mockDeleteFolder.call(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return const Right(true);
        });
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(
          const ArchivePageEvent.deleteFolder(
            relativePath: 'Vacanze',
            isPrivate: true,
          ),
        );
        // Sample the state while the delete usecase is still running.
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      verify: (bloc) {
        final folderNames = bloc.state.maybeMap(
          ui: (u) => u.folders.map((f) => f.name).toList(),
          orElse: () => <String>['<not-ui>'],
        );
        expect(folderNames, isNot(contains('Vacanze')));
      },
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'deleteFolder rolls the folder back and surfaces failure when the '
      'delete usecase returns Left',
      build: () {
        seedNested();
        when(() => mockDeleteFolder.call(any())).thenAnswer(
          (_) async => Left(EncryptionFailure.encryptionError('disk error')),
        );
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(
          const ArchivePageEvent.deleteFolder(
            relativePath: 'Vacanze',
            isPrivate: true,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      },
      verify: (bloc) {
        // Final emitted state restores the folder (rollback re-emits ui).
        final folderNames = bloc.state.maybeMap(
          ui: (u) => u.folders.map((f) => f.name).toList(),
          orElse: () => <String>['<not-ui>'],
        );
        expect(folderNames, contains('Vacanze'));
        // Images under the folder are back in the in-memory model.
        expect(
          bloc.images.map((i) => i.storagePath.path),
          containsAll(<String>[
            '/app/encrypted/Vacanze/a.png',
            '/app/encrypted/Vacanze/Mare/b.png',
          ]),
        );
      },
    );

    blocTest<ArchivePageBloc, ArchivePageState>(
      'decryptFolder starts a background job for the folder',
      build: () {
        seedNested();
        return makeBloc();
      },
      act: (b) async {
        b.add(const ArchivePageEvent.setup());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        b.add(
          const ArchivePageEvent.decryptFolder(
            relativePath: 'Vacanze',
            isPrivate: true,
            passphrase: 'pw',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 30));
      },
      verify: (_) {
        verify(
          () => mockDecryptJobManager.start(
            key: DecryptJobManager.keyFor(
              isPrivate: true,
              relativePath: 'Vacanze',
            ),
            images: any(named: 'images'),
            password: 'pw',
          ),
        ).called(1);
      },
    );
  });
}
