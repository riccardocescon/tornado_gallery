import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/failures/failures.dart';

abstract class EncryptionUseCase<T, Params> {
  Future<Either<EncryptionFailure, T>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<Either<DecryptionFailure, T>> call(Params params);
}
