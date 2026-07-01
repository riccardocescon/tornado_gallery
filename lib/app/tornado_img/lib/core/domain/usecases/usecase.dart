import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/failures/failures.dart';
import 'package:tornado_img_app/core/utils/globals.dart';

abstract class EncryptionUseCase<T, Params> {
  Future<Either<EncryptionFailure, T>> call(Params params);

  /// Runs [body] and, on any thrown error, logs [errorLog] and converts it to
  /// a `Left(EncryptionFailure.encryptionError(...))`. [body] may itself return
  /// a `Left` for validation failures — those pass through unchanged.
  ///
  /// Centralises the try/catch + log + wrap boilerplate shared by the simple
  /// use cases.
  Future<Either<EncryptionFailure, T>> guardEither(
    String errorLog,
    Future<Either<EncryptionFailure, T>> Function() body,
  ) async {
    try {
      return await body();
    } catch (e) {
      appLogger.log(errorLog, LogLayer.usecase, error: e.toString());
      return Left(EncryptionFailure.encryptionError(e.toString()));
    }
  }
}

abstract class StreamUseCase<T, Params> {
  Stream<Either<DecryptionFailure, T>> call(Params params);
}
