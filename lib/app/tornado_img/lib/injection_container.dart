import 'package:get_it/get_it.dart';
import 'package:tornado_img_app/core/data/repositories/encrypted_gallery_repository/encrypted_gallery_repository_impl.dart';
import 'package:tornado_img_app/core/data/repositories/image_processing_repository_impl.dart';
import 'package:tornado_img_app/core/data/repositories/storage_repository_impl.dart';
import 'package:tornado_img_app/core/domain/repositories/encrypted_gallery_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository_impl.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_gallery_page_bloc/encrypted_gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';

GetIt getIt = GetIt.instance;

void setupInjectionContainer() {
  getIt.registerLazySingleton(() => ThemeNotifier());
  getIt.registerLazySingleton(() => GalleryBloc(getIt()));
  getIt.registerLazySingleton(() => EncryptedGalleryBloc(getIt()));
  getIt.registerFactory(() => HomepageBloc());
  getIt.registerFactory(() => GalleryPageBloc());
  getIt.registerFactory(() => EncrpytedGalleryPageBloc());

  getIt.registerLazySingleton<EncryptImageUseCase>(
    () => EncryptImageUseCase(imageRepo: getIt(), storageRepo: getIt()),
  );
  getIt.registerLazySingleton<EncryptedGalleryRepository>(
    () => EncryptedGalleryRepositoryImpl(),
  );

  getIt.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl());
  getIt.registerLazySingleton<ImageProcessingRepository>(
    () => ImageProcessingRepositoryImpl(),
  );
}
