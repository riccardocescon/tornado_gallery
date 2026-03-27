import 'package:dartz/dartz.dart';
import 'package:tornado_img_app/core/failues/failures.dart';

abstract class EncrpytionUseCase<T, Params> {
  Future<Either<EncryptionFailure, T>> call(Params params);
}

abstract class GalleryReaderUseCase<T, Params> {
  Stream<Either<DecryptionFailure, T>> call(Params params);
}
