import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/managers/decrypt_job_manager.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';

class _MockDecryptUseCase extends Mock implements DecryptImageUseCase {}

class _MockAppBloc extends Mock implements AppBloc {}

EncryptedImage _img(String path) => EncryptedImage(
  storagePath: StoragePath(path: path, isPrivateFolder: true, assetId: null),
  encryptedInfo: BytesInfo(bytes: Uint8List(0), hash: ''),
  date: DateTime(2024),
);

BytesInfo _bytes() => BytesInfo(bytes: Uint8List(1), hash: 'h');

void main() {
  late _MockDecryptUseCase decrypt;
  late _MockAppBloc appBloc;
  late DecryptJobManager manager;

  setUpAll(() {
    registerFallbackValue(
      DecryptImageParams(file: _img('x').storagePath.file, password: ''),
    );
    registerFallbackValue(
      AppEvent.setDecryptedInfo(path: 'x', decryptedInfo: null),
    );
  });

  setUp(() {
    decrypt = _MockDecryptUseCase();
    appBloc = _MockAppBloc();
    when(() => appBloc.add(any())).thenReturn(null);
    manager = DecryptJobManager(decryptUseCase: decrypt, appBloc: appBloc);
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

  test('already-decrypted images are skipped (no job)', () {
    final done = _img('/a.png').copyWith(decryptInfo: _bytes());
    manager.start(key: 'k', images: [done], password: 'pw');

    expect(manager.isRunning('k'), isFalse);
    verifyNever(() => decrypt.call(any()));
  });
}
