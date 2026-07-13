import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';

class _MockAppBloc extends Mock implements AppBloc {}

class _MockGalleryBloc extends Mock implements GalleryBloc {}

class _MockPurchaseBloc extends Mock implements PurchaseBloc {}

EncryptedImage _encrypted(int i) => EncryptedImage(
  storagePath: StoragePath(
    path: 'img$i.png',
    isPrivateFolder: true,
    assetId: null,
  ),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

GalleryImage _selected(int i) =>
    GalleryImage(id: '$i', file: File('pick$i.png'), date: DateTime(2024));

void main() {
  late _MockAppBloc appBloc;
  late _MockGalleryBloc galleryBloc;
  late _MockPurchaseBloc purchaseBloc;

  setUpAll(() {
    registerFallbackValue(AppEvent.addEncryptedImage(image: _encrypted(0)));
    registerFallbackValue(
      GalleryEvent.encryptImages(
        images: const {},
        password: '',
        settings: EncryptionSettings.init(),
      ),
    );
  });

  setUp(() {
    appBloc = _MockAppBloc();
    galleryBloc = _MockGalleryBloc();
    purchaseBloc = _MockPurchaseBloc();

    when(() => appBloc.add(any())).thenReturn(null);
    when(() => galleryBloc.add(any())).thenReturn(null);
    when(() => galleryBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  EncryptionPageBloc makeBloc({
    required int alreadyEncrypted,
    required bool isPro,
  }) {
    when(
      () => appBloc.encryptedImages,
    ).thenReturn([for (var i = 0; i < alreadyEncrypted; i++) _encrypted(i)]);
    when(() => purchaseBloc.isPro).thenReturn(isPro);

    return EncryptionPageBloc(
      appBloc: appBloc,
      galleryBloc: galleryBloc,
      purchaseBloc: purchaseBloc,
    );
  }

  /// Puts [count] images on the page. The real `setup` event stats each file on
  /// disk, which these tests have no business faking — the cap only cares how
  /// many images are selected.
  void select(EncryptionPageBloc bloc, int count) {
    bloc.images.addAll([for (var i = 0; i < count; i++) _selected(i)]);
  }

  group('exceedsFreeLimit — the cap the Encrypt button is disabled on', () {
    test('a free user landing exactly on the cap is allowed', () {
      final bloc = makeBloc(
        alreadyEncrypted: Constants.maxEncryptedImages - 2,
        isPro: false,
      );
      select(bloc, 2);

      expect(bloc.exceedsFreeLimit, isFalse);
    });

    test('one image past the cap blocks a free user', () {
      final bloc = makeBloc(
        alreadyEncrypted: Constants.maxEncryptedImages - 2,
        isPro: false,
      );
      select(bloc, 3);

      expect(bloc.exceedsFreeLimit, isTrue);
    });

    test('a Pro user is never blocked', () {
      final bloc = makeBloc(
        alreadyEncrypted: Constants.maxEncryptedImages * 5,
        isPro: true,
      );
      select(bloc, 50);

      expect(bloc.exceedsFreeLimit, isFalse);
    });
  });

  blocTest<EncryptionPageBloc, EncryptionPageState>(
    'encrypt past the cap emits limitReached and never starts encrypting',
    build: () {
      final bloc = makeBloc(
        alreadyEncrypted: Constants.maxEncryptedImages,
        isPro: false,
      );
      select(bloc, 1);
      bloc.password = 'hunter2';
      return bloc;
    },
    act: (bloc) => bloc.add(const EncryptionPageEvent.encrypt()),
    // Nothing else: the guard must fire *before* `encrypting` is announced,
    // otherwise the progress UI flashes for a frame on the way to the paywall.
    expect: () => [const EncryptionPageState.limitReached()],
    verify: (_) {
      verifyNever(() => galleryBloc.add(any()));
    },
  );
}
