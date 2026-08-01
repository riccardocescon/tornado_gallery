import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/data/video_crypto/cosmetic_mp4_builder.dart';
import 'package:tornado_img_app/core/domain/entities/image_data.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';

class _MockImageProcessingRepository extends Mock
    implements ImageProcessingRepository {}

class _FakeImageData extends Fake implements ImageData {}

void main() {
  group('evenDimensions', () {
    test('leaves both-even dimensions unchanged', () {
      expect(evenDimensions(720, 480), (720, 480));
    });

    test('rounds both-odd dimensions up by one', () {
      expect(evenDimensions(721, 481), (722, 482));
    });

    test('rounds only the odd side of a mixed pair', () {
      expect(evenDimensions(721, 480), (722, 480));
      expect(evenDimensions(720, 481), (720, 482));
    });

    test('rounds 1x1 up to 2x2', () {
      expect(evenDimensions(1, 1), (2, 2));
    });

    test('leaves 0x0 unchanged (already even)', () {
      expect(evenDimensions(0, 0), (0, 0));
    });
  });

  group('CosmeticMp4Builder.build failure paths', () {
    late _MockImageProcessingRepository mockImageRepo;
    late CosmeticMp4Builder builder;
    final tPosterBytes = Uint8List.fromList([1, 2, 3]);

    setUpAll(() {
      registerFallbackValue(_FakeImageData());
      registerFallbackValue('');
      registerFallbackValue(Uint8List(0));
    });

    setUp(() {
      mockImageRepo = _MockImageProcessingRepository();
      builder = CosmeticMp4Builder(imageRepo: mockImageRepo);
    });

    // These exercise only the repository-driven scrambling step, which runs
    // entirely before the (device-only) native encoder is touched: both
    // failure branches throw before reaching image.decodePng or the encoder.

    test('throws when decodeBytes returns null', () async {
      when(
        () => mockImageRepo.decodeBytes(any(), extension: any(named: 'extension')),
      ).thenAnswer((_) async => null);

      expect(
        () => builder.build(posterBytes: tPosterBytes, password: 'secret'),
        throwsStateError,
      );
      verifyNever(() => mockImageRepo.encrypt(any(), any()));
    });

    test('throws when encode returns null', () async {
      final tImageData = _FakeImageData();
      when(
        () => mockImageRepo.decodeBytes(any(), extension: any(named: 'extension')),
      ).thenAnswer((_) async => tImageData);
      when(
        () => mockImageRepo.encrypt(any(), any()),
      ).thenAnswer((_) async => tImageData);
      when(() => mockImageRepo.encode(any())).thenAnswer((_) async => null);

      expect(
        () => builder.build(posterBytes: tPosterBytes, password: 'secret'),
        throwsStateError,
      );
    });
  });
}
