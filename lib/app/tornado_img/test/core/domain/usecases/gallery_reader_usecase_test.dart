import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_stream_image.dart';

class _MockImageProcessingRepository extends Mock
    implements ImageProcessingRepository {}

class _MockStorageRepository extends Mock implements StorageRepository {}

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

EncryptedStreamImage _makeStreamImage(String path) =>
    EncryptedStreamImage.image(
      image: EncryptedImage(
        path: path,
        encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
        date: DateTime(2024),
        isPrivateFolder: true,
      ),
      type: EncryptedStreamImageType.newImage,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockImageProcessingRepository mockImageRepo;
  late _MockStorageRepository mockStorageRepo;
  late GalleryReaderUsecase useCase;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gallery_reader_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    mockImageRepo = _MockImageProcessingRepository();
    mockStorageRepo = _MockStorageRepository();
    useCase = GalleryReaderUsecase(
      imageRepo: mockImageRepo,
      storageRepo: mockStorageRepo,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('GalleryReaderUsecase.call', () {
    test('yields Right for each private image', () async {
      final img1 = _makeStreamImage('/enc/img1.png');
      final img2 = _makeStreamImage('/enc/img2.png');

      when(
        () => mockStorageRepo.readPrivateImages(any()),
      ).thenAnswer((_) => Stream.fromIterable([img1, img2]));
      when(
        () => mockStorageRepo.readPublicGalleryImages(),
      ).thenAnswer((_) => const Stream.empty());

      final results = await useCase.call(null).toList();

      expect(results.length, 2);
      expect(results.every((r) => r.isRight()), isTrue);
    });

    test('yields Right for both private and public images', () async {
      final privateImg = _makeStreamImage('/enc/private.png');
      final publicImg = _makeStreamImage('/public/pub.png');

      when(
        () => mockStorageRepo.readPrivateImages(any()),
      ).thenAnswer((_) => Stream.fromIterable([privateImg]));
      when(
        () => mockStorageRepo.readPublicGalleryImages(),
      ).thenAnswer((_) => Stream.fromIterable([publicImg]));

      final results = await useCase.call(null).toList();

      expect(results.length, 2);
      expect(results.every((r) => r.isRight()), isTrue);
    });

    test('yields nothing when both streams are empty', () async {
      when(
        () => mockStorageRepo.readPrivateImages(any()),
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockStorageRepo.readPublicGalleryImages(),
      ).thenAnswer((_) => const Stream.empty());

      final results = await useCase.call(null).toList();

      expect(results, isEmpty);
    });

    test(
      'stream errors from readPrivateImages propagate to consumer',
      () async {
        when(
          () => mockStorageRepo.readPrivateImages(any()),
        ).thenAnswer((_) => Stream.error(Exception('read error')));
        when(
          () => mockStorageRepo.readPublicGalleryImages(),
        ).thenAnswer((_) => const Stream.empty());

        // Stream errors from yield* propagate through the async* generator —
        // they are NOT caught by the outer try/catch and reach the consumer.
        expect(() => useCase.call(null).toList(), throwsA(isA<Exception>()));
      },
    );

    test('private images path uses application documents directory', () async {
      String? capturedPath;

      when(() => mockStorageRepo.readPrivateImages(any())).thenAnswer((inv) {
        capturedPath = inv.positionalArguments.first as String;
        return const Stream.empty();
      });
      when(
        () => mockStorageRepo.readPublicGalleryImages(),
      ).thenAnswer((_) => const Stream.empty());

      await useCase.call(null).drain<void>();

      expect(capturedPath, isNotNull);
      expect(capturedPath, contains('encrypted'));
    });
  });
}
