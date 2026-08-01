import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/features/presentation/pages/video_player_page/video_player_page.dart';
import 'package:tornado_img_app/theme/theme.dart';

class _MockDecryptVideoUseCase extends Mock implements DecryptVideoUseCase {}

/// A real 2×2 PNG: the page renders the poster with `Image.memory`, which
/// throws on garbage bytes and would fail the test for the wrong reason.
Uint8List _posterPng() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));

void main() {
  late _MockDecryptVideoUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      DecryptVideoParams(encryptedPath: '', password: ''),
    );
  });

  setUp(() => useCase = _MockDecryptVideoUseCase());

  EncryptedImage videoImage() {
    final poster = _posterPng();
    return EncryptedImage(
      storagePath: StoragePath(
        path: '${Directory.systemTemp.path}/clip.mp4',
        isPrivateFolder: true,
        assetId: null,
      ),
      encryptedInfo: BytesInfo(bytes: poster, hash: 'hash'),
      date: DateTime(2026, 8, 1),
    );
  }

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: VideoPlayerPage(image: videoImage(), decryptUseCase: useCase),
    ),
  );

  testWidgets('shows the failure message when decryption fails', (
    tester,
  ) async {
    when(() => useCase.call(any())).thenAnswer(
      (_) async => Left(EncryptionFailure.wrongPassword()),
    );

    await pumpPage(tester);
    await tester.enterText(find.byType(TextFormField), 'wrong-pw');
    // The page sweeps the temp dir (real dart:io) before decrypting, and real
    // I/O never completes inside the fake-async zone `pump` runs in.
    await tester.runAsync(() async {
      await tester.tap(find.text('Decrypt and play'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.text('Wrong password'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget, reason: 'still asking');
  });

  testWidgets('refuses to decrypt with an empty password', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Decrypt and play'));
    await tester.pumpAndSettle();

    expect(find.text('Password cannot be empty'), findsOneWidget);
    verifyNever(() => useCase.call(any()));
  });
}
