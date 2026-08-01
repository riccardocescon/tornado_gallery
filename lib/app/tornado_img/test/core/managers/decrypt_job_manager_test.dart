import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_video_usecase.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/managers/decrypt_job_manager.dart';
import 'package:tornado_img_app/core/managers/decrypted_video_cache.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';

class _MockDecryptUseCase extends Mock implements DecryptImageUseCase {}

class _MockDecryptVideoUseCase extends Mock implements DecryptVideoUseCase {}

class _MockVideoCache extends Mock implements DecryptedVideoCache {}

class _MockAppBloc extends Mock implements AppBloc {}

EncryptedImage _img(String path) => EncryptedImage(
  storagePath: StoragePath(path: path, isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

BytesInfo _bytes() => BytesInfo(bytes: Uint8List(1), hash: 'h');

void main() {
  late _MockDecryptUseCase decrypt;
  late _MockDecryptVideoUseCase decryptVideo;
  late _MockVideoCache videoCache;
  late _MockAppBloc appBloc;
  late DecryptJobManager manager;

  setUpAll(() {
    registerFallbackValue(
      DecryptImageParams(file: _img('x').storagePath.file, password: ''),
    );
    registerFallbackValue(
      DecryptVideoParams(encryptedPath: 'x', password: ''),
    );
    registerFallbackValue(File('x'));
    registerFallbackValue(
      AppEvent.setDecryptedInfo(path: 'x', decryptedInfo: null),
    );
  });

  setUp(() {
    decrypt = _MockDecryptUseCase();
    decryptVideo = _MockDecryptVideoUseCase();
    videoCache = _MockVideoCache();
    appBloc = _MockAppBloc();
    when(() => appBloc.add(any())).thenReturn(null);
    when(() => videoCache.entry(any())).thenReturn(null);
    when(() => videoCache.sweepOnce()).thenAnswer((_) async {});
    when(() => videoCache.put(any(), any())).thenReturn(null);
    manager = DecryptJobManager(
      decryptUseCase: decrypt,
      decryptVideoUseCase: decryptVideo,
      videoCache: videoCache,
      appBloc: appBloc,
    );
  });

  test('keyFor distinguishes store and path', () {
    expect(
      DecryptJobManager.keyFor(isPrivate: true, relativePath: 'A'),
      isNot(DecryptJobManager.keyFor(isPrivate: false, relativePath: 'A')),
    );
  });

  test('decrypts every pending image and commits to AppBloc', () async {
    when(() => decrypt.call(any())).thenAnswer((_) async => Right(_bytes()));

    manager.start(
      key: 'k',
      images: [_img('/a.png'), _img('/b.png')],
      password: 'pw',
    );

    await manager.updates.firstWhere((_) => !manager.isRunning('k'));

    verify(() => appBloc.add(any())).called(2);
    expect(manager.isRunning('k'), isFalse);
    expect(manager.jobState('k'), isNull); // dropped once finished
  });

  test('runs two folder jobs in parallel', () async {
    when(() => decrypt.call(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return Right(_bytes());
    });

    manager.start(key: 'a', images: [_img('/a.png')], password: 'pw');
    manager.start(key: 'b', images: [_img('/b.png')], password: 'pw');

    // Both jobs are tracked concurrently before either finishes.
    expect(manager.isRunning('a'), isTrue);
    expect(manager.isRunning('b'), isTrue);

    await manager.updates.firstWhere(
      (_) => !manager.isRunning('a') && !manager.isRunning('b'),
    );

    verify(() => appBloc.add(any())).called(2);
  });

  test('a video is decrypted to a temp file and its poster committed', () async {
    final plaintext = File('/tmp/a.mp4');
    when(
      () => decryptVideo.call(any()),
    ).thenAnswer((_) async => Right(plaintext));
    when(() => decrypt.call(any())).thenAnswer((_) async => Right(_bytes()));

    manager.start(key: 'k', images: [_img('/a.mp4')], password: 'pw');
    await manager.updates.firstWhere((_) => !manager.isRunning('k'));

    verify(() => videoCache.put('/a.mp4', plaintext)).called(1);
    verify(() => appBloc.add(any())).called(1);
  });

  test('a video with the wrong password fails without touching the cache', () async {
    when(
      () => decryptVideo.call(any()),
    ).thenAnswer((_) async => Left(EncryptionFailure.wrongPassword()));

    manager.start(key: 'k', images: [_img('/a.mp4')], password: 'nope');
    await manager.updates.firstWhere((_) => !manager.isRunning('k'));

    verifyNever(() => videoCache.put(any(), any()));
    verifyNever(() => decrypt.call(any()));
    verifyNever(() => appBloc.add(any()));
  });

  test('already-decrypted images are skipped (no job)', () {
    final done = _img('/a.png').copyWith(decryptInfo: _bytes());
    manager.start(key: 'k', images: [done], password: 'pw');

    expect(manager.isRunning('k'), isFalse);
    verifyNever(() => decrypt.call(any()));
  });
}
