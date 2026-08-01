import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/video_saver_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/video_player_page/video_player_page.dart';
import 'package:tornado_img_app/features/presentation/widgets/rename_bottom_sheet.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:tornado_img_app/theme/theme.dart';

class _MockDecryptVideoUseCase extends Mock implements DecryptVideoUseCase {}

class _MockVideoSaverUseCase extends Mock implements VideoSaverUseCase {}

class _MockImageRenamerUseCase extends Mock implements ImageRenamerUseCase {}

/// A real 2×2 PNG: the page renders the poster with `Image.memory`, which
/// throws on garbage bytes and would fail the test for the wrong reason.
Uint8List _posterPng() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));

void main() {
  late _MockDecryptVideoUseCase decryptUseCase;
  late _MockVideoSaverUseCase saveUseCase;
  late _MockImageRenamerUseCase renameUseCase;
  late AppBloc appBloc;
  late DecryptedVideoCache videoCache;

  final videoPath = '${Directory.systemTemp.path}/clip.mp4';

  setUpAll(() {
    registerFallbackValue(DecryptVideoParams(encryptedPath: '', password: ''));
    registerFallbackValue(VideoSaverParams(filePath: ''));
    registerFallbackValue(
      ImageRenamerParams(path: '', oldFileName: '', newFileName: ''),
    );
  });

  setUp(() {
    decryptUseCase = _MockDecryptVideoUseCase();
    saveUseCase = _MockVideoSaverUseCase();
    renameUseCase = _MockImageRenamerUseCase();
    appBloc = AppBloc();
    videoCache = DecryptedVideoCache();

    // The shared RenameBottomSheet validates the new name against AppBloc's
    // in-memory list, which it resolves from get_it.
    if (getIt.isRegistered<AppBloc>()) getIt.unregister<AppBloc>();
    getIt.registerSingleton<AppBloc>(appBloc);
  });

  tearDown(() async {
    await appBloc.close();
    await getIt.reset();
  });

  EncryptedImage videoImage() => EncryptedImage(
    storagePath: StoragePath(
      path: videoPath,
      isPrivateFolder: true,
      assetId: null,
    ),
    encryptedInfo: BytesInfo(bytes: _posterPng(), hash: 'hash'),
    date: DateTime(2026, 8, 1),
  );

  Future<void> pumpPage(WidgetTester tester) async {
    // The full detail layout (preview + info + actions) is taller than the
    // 800×600 default surface, and off-screen widgets cannot be tapped.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      BlocProvider.value(
        value: appBloc,
        child: MaterialApp(
          theme: AppTheme.light,
          home: VideoPlayerPage(
            image: videoImage(),
            decryptUseCase: decryptUseCase,
            saveUseCase: saveUseCase,
            renameUseCase: renameUseCase,
            videoCache: videoCache,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the image-page layout while still locked', (tester) async {
    await pumpPage(tester);

    expect(find.text('Encrypted Video'), findsOneWidget);
    expect(find.text('Start Decryption'), findsOneWidget);
    expect(find.text('Actions'), findsOneWidget);
    expect(find.text('Save video'), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
    // Info rows.
    expect(find.text('Name:'), findsOneWidget);
    expect(find.text('Size:'), findsOneWidget);
    expect(find.text('Created:'), findsOneWidget);
    expect(find.text('Path:'), findsOneWidget);
  });

  testWidgets('shows the failure message when decryption fails', (
    tester,
  ) async {
    when(
      () => decryptUseCase.call(any()),
    ).thenAnswer((_) async => Left(EncryptionFailure.wrongPassword()));

    await pumpPage(tester);
    await tester.enterText(find.byType(TextFormField), 'wrong-pw');
    // The page sweeps the temp dir (real dart:io) before decrypting, and real
    // I/O never completes inside the fake-async zone `pump` runs in.
    await tester.runAsync(() async {
      await tester.tap(find.text('Start Decryption'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.text('Wrong password'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget, reason: 'still asking');
  });

  testWidgets('refuses to decrypt with an empty password', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Start Decryption'));
    await tester.pumpAndSettle();

    expect(find.text('Password cannot be empty'), findsOneWidget);
    verifyNever(() => decryptUseCase.call(any()));
  });

  testWidgets('save hands the still-encrypted file over by path', (
    tester,
  ) async {
    when(
      () => saveUseCase.call(any()),
    ).thenAnswer((_) async => const Right(null));

    await pumpPage(tester);
    await tester.tap(find.text('Save video'));
    await tester.pumpAndSettle();

    final params =
        verify(() => saveUseCase.call(captureAny())).captured.single
            as VideoSaverParams;
    // No decryption happened, so it is the source file — never its bytes.
    expect(params.filePath, videoPath);
    expect(find.textContaining('Video saved to gallery'), findsOneWidget);
  });

  testWidgets('rename renames the file on disk and updates AppBloc', (
    tester,
  ) async {
    when(
      () => renameUseCase.call(any()),
    ).thenAnswer((_) async => const Right(StorageRenameResult(success: true)));

    await pumpPage(tester);
    appBloc.add(AppEvent.addEncryptedImage(image: videoImage()));
    await tester.pumpAndSettle();

    // Stand in for a cached plaintext: the rename must carry the entry over to
    // the new path, or the next visit re-asks for the password.
    // Sync I/O: inside `testWidgets` the fake-async zone never completes real
    // async file operations.
    final plaintext = File('${Directory.systemTemp.path}/clip-plain.mp4');
    plaintext.writeAsBytesSync(<int>[0]);
    addTearDown(() {
      if (plaintext.existsSync()) plaintext.deleteSync();
    });
    videoCache.put(videoPath, plaintext);

    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(RenameBottomSheet),
        matching: find.byType(TextFormField),
      ),
      'holiday',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Rename'));
    await tester.pumpAndSettle();

    final params =
        verify(() => renameUseCase.call(captureAny())).captured.single
            as ImageRenamerParams;
    expect(params.oldFileName, 'clip.mp4');
    expect(params.newFileName, 'holiday.mp4');
    expect(find.text('Video renamed successfully'), findsOneWidget);
    expect(appBloc.encryptedImages.single.name, 'holiday.mp4');
    expect(videoCache.entry(videoPath), isNull);
    expect(
      videoCache.entry('${Directory.systemTemp.path}/holiday.mp4'),
      isNotNull,
    );
  });
}
