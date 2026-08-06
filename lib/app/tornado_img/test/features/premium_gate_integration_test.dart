import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tornado_img_app/core/data/datasources/purchase_datasource.dart';
import 'package:tornado_img_app/core/data/repositories/purchase_repository/purchase_repository_impl.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_stream_image.dart';
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
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:dartz/dartz.dart';

/// End-to-end premium gate: a REAL PurchaseRepositoryImpl → REAL PurchaseBloc →
/// REAL gate blocs, with only the store boundary (PurchaseDatasource) mocked.
/// This is the safety net that fails if any release quietly breaks the paid
/// limits — free users must stay capped, and a purchase must lift the caps.

class _MockPurchaseDatasource extends Mock implements PurchaseDatasource {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockGalleryBloc extends Mock implements GalleryBloc {}

class _MockGalleryReaderUsecase extends Mock implements GalleryReaderUseCase {}

class _MockImageDeleterUsecase extends Mock implements ImageDeleterUseCase {}

class _MockImageSaverUsecase extends Mock implements ImageSaverUseCase {}

class _MockCreateFolderUsecase extends Mock implements CreateFolderUseCase {}

class _MockRenameFolderUsecase extends Mock implements RenameFolderUseCase {}

class _MockDeleteFolderUsecase extends Mock implements DeleteFolderUseCase {}

class _MockMoveImagesUsecase extends Mock implements MoveImagesUseCase {}

class _MockDecryptJobManager extends Mock implements DecryptJobManager {}

class _FakePurchaseDetails extends Fake implements PurchaseDetails {
  _FakePurchaseDetails({required this.productID, required this.status});

  @override
  final String productID;
  @override
  final PurchaseStatus status;

  @override
  bool get pendingCompletePurchase => true;
}

EncryptedImage _encrypted(String path) => EncryptedImage(
  storagePath: StoragePath(path: path, isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

EncryptedStreamImage _streamImage(String path) => EncryptedStreamImage.image(
  image: _encrypted(path),
  type: EncryptedStreamImageType.newImage,
);

GalleryImage _picked(int i) =>
    GalleryImage(id: '$i', file: File('pick$i.png'), date: DateTime(2024));

void main() {
  late _MockPurchaseDatasource store;
  late StreamController<List<PurchaseDetails>> purchases;
  late SharedPreferences prefs;
  late PurchaseRepositoryImpl repo;
  late PurchaseBloc purchaseBloc;

  setUpAll(() {
    registerFallbackValue(
      _FakePurchaseDetails(
        productID: Constants.proMonthlyId,
        status: PurchaseStatus.purchased,
      ),
    );
    registerFallbackValue(
      CreateFolderParams(parentRelativePath: '', name: 'x', isPrivate: true),
    );
    registerFallbackValue(
      AppEvent.folderCreated(isPrivate: true, relativePath: 'x'),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    store = _MockPurchaseDatasource();
    purchases = StreamController<List<PurchaseDetails>>.broadcast();
    when(() => store.purchases).thenAnswer((_) => purchases.stream);
    when(() => store.isAvailable()).thenAnswer((_) async => true);
    when(() => store.restore()).thenAnswer((_) async {});
    when(() => store.complete(any())).thenAnswer((_) async {});

    repo = PurchaseRepositoryImpl(datasource: store, preferences: prefs);
    purchaseBloc = PurchaseBloc(purchaseRepository: repo);
  });

  tearDown(() async {
    await purchaseBloc.close();
    await repo.dispose();
    await purchases.close();
  });

  /// Subscribes the repo to the store and confirms we start on the free tier
  /// (no purchase seeded, `kDebugMode == false` under `flutter test`).
  Future<void> startFree() async {
    await repo.setup();
    expect(purchaseBloc.isPro, isFalse, reason: 'no purchase yet');
  }

  /// Drives a real "purchased" event through the mocked store, exactly as the
  /// plugin would, and lets the repository grant Pro.
  Future<void> pushPurchase(String productId) async {
    purchases.add([
      _FakePurchaseDetails(productID: productId, status: PurchaseStatus.purchased),
    ]);
    await Future<void>.delayed(Duration.zero);
  }

  group('image cap', () {
    late _MockAppBloc appBloc;
    late _MockGalleryBloc galleryBloc;

    setUp(() {
      appBloc = _MockAppBloc();
      galleryBloc = _MockGalleryBloc();
      // Archive already sitting exactly on the free cap.
      when(() => appBloc.encryptedImages).thenReturn([
        for (var i = 0; i < Constants.maxEncryptedImages; i++)
          _encrypted('img$i.png'),
      ]);
    });

    test('a purchase lifts the image cap on an already-open encryption page',
        () async {
      await startFree();

      final enc = EncryptionPageBloc(
        appBloc: appBloc,
        galleryBloc: galleryBloc,
        purchaseBloc: purchaseBloc,
      );
      enc.images.add(_picked(0)); // one more than the cap allows

      expect(
        enc.exceedsFreeLimit,
        isTrue,
        reason: 'free user past ${Constants.maxEncryptedImages} is blocked',
      );

      await pushPurchase(Constants.proMonthlyId);

      expect(purchaseBloc.isPro, isTrue);
      expect(
        enc.exceedsFreeLimit,
        isFalse,
        reason: 'the same page unlocks the moment the purchase lands',
      );

      await enc.close();
    });
  });

  group('archive cap', () {
    late _MockAppBloc appBloc;
    late _MockGalleryReaderUsecase galleryReader;
    late _MockImageDeleterUsecase imageDeleter;
    late _MockImageSaverUsecase imageSaver;
    late _MockCreateFolderUsecase createFolder;
    late _MockRenameFolderUsecase renameFolder;
    late _MockDeleteFolderUsecase deleteFolder;
    late _MockMoveImagesUsecase moveImages;
    late _MockDecryptJobManager decryptJobManager;

    setUp(() {
      appBloc = _MockAppBloc();
      galleryReader = _MockGalleryReaderUsecase();
      imageDeleter = _MockImageDeleterUsecase();
      imageSaver = _MockImageSaverUsecase();
      createFolder = _MockCreateFolderUsecase();
      renameFolder = _MockRenameFolderUsecase();
      deleteFolder = _MockDeleteFolderUsecase();
      moveImages = _MockMoveImagesUsecase();
      decryptJobManager = _MockDecryptJobManager();

      when(() => appBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => appBloc.encryptedImages).thenReturn([]);
      when(() => appBloc.add(any())).thenReturn(null);

      // Seed exactly maxArchives folders through the real setup pipeline.
      when(() => galleryReader.call(null)).thenAnswer(
        (_) => Stream.fromIterable([
          for (var i = 0; i < Constants.maxArchives; i++)
            Right<DecryptionFailure, EncryptedStreamImage>(
              _streamImage('/app/encrypted/Archive$i/img.png'),
            ),
        ]),
      );
      when(() => galleryReader.readPrivateFolderPaths())
          .thenAnswer((_) => const Stream.empty());
      when(() => galleryReader.readPublicFolderPaths())
          .thenAnswer((_) => const Stream.empty());
      when(() => decryptJobManager.updates)
          .thenAnswer((_) => const Stream.empty());
      when(() => createFolder.call(any()))
          .thenAnswer((_) async => const Right(true));
    });

    ArchivePageBloc makeArchive() => ArchivePageBloc(
      appBloc: appBloc,
      purchaseBloc: purchaseBloc,
      decryptJobManager: decryptJobManager,
      galleryReaderUseCase: galleryReader,
      imageDeleterUseCase: imageDeleter,
      imageSaverUseCase: imageSaver,
      createFolderUseCase: createFolder,
      renameFolderUseCase: renameFolder,
      deleteFolderUseCase: deleteFolder,
      moveImagesUseCase: moveImages,
    );

    test('a purchase lifts the archive cap and lets the folder be created',
        () async {
      await startFree();

      final arc = makeArchive();
      arc.add(const ArchivePageEvent.setup());
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        arc.archiveCount,
        Constants.maxArchives,
        reason: 'the seeded tree sits on the cap',
      );
      expect(
        arc.exceedsFreeLimit,
        isTrue,
        reason: 'free user at ${Constants.maxArchives} archives is blocked',
      );

      // Blocked: creating one more must not reach the use case.
      arc.add(const ArchivePageEvent.createFolder(name: 'BlockedByCap'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      verifyNever(() => createFolder.call(any()));

      await pushPurchase(Constants.proLifetimeId);
      expect(purchaseBloc.isPro, isTrue);
      expect(arc.exceedsFreeLimit, isFalse, reason: 'Pro is uncapped');

      // Now allowed: the create flows through to the use case.
      arc.add(const ArchivePageEvent.createFolder(name: 'OneMore'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      verify(() => createFolder.call(any())).called(1);

      await arc.close();
    });
  });
}
