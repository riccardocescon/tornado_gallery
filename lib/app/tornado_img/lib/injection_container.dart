import 'package:get_it/get_it.dart';
import 'package:tornado_img_app/core/data/repositories/image_processing_repository_impl.dart';
import 'package:tornado_img_app/core/data/whats_new_service.dart';
import 'package:tornado_img_app/core/utils/globals.dart';
import 'package:tornado_img_app/core/data/repositories/storage_repository/storage_repository_impl.dart';
import 'package:tornado_img_app/core/domain/repositories/image_processing_repository.dart';
import 'package:tornado_img_app/core/domain/repositories/storage_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/create_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/decrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/delete_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/encrypt_image_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/gallery_reader_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_deleter_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/move_images_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/rename_folder_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_renamer_usecase.dart';
import 'package:tornado_img_app/core/domain/usecases/image_saver_usecase.dart';
import 'package:tornado_img_app/core/data/datasources/purchase_datasource.dart';
import 'package:tornado_img_app/core/data/repositories/purchase_repository/purchase_repository_impl.dart';
import 'package:tornado_img_app/core/domain/repositories/purchase_repository.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/purchase_bloc/purchase_bloc.dart';
import 'package:tornado_img_app/core/data/repositories/app_repository/app_repository_impl.dart';
import 'package:tornado_img_app/core/domain/repositories/app_repository.dart';
import 'package:tornado_img_app/core/domain/usecases/app_folder_streamer_usecase.dart';
import 'package:tornado_img_app/core/managers/decrypt_job_manager.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/theme/theme_notifier.dart';

GetIt getIt = GetIt.instance;

/// Registration lifetimes:
///
/// - **Lazy singletons** for app-wide, long-lived collaborators that must share
///   one instance: the canonical stores/blocs ([AppBloc], [GalleryBloc],
///   [HomepageBloc]), the stateless use cases, and the repositories.
/// - **Factories** for per-screen blocs ([EncryptionPageBloc],
///   [ArchivePageBloc], [EncryptedImagePageBloc]) so each page/route gets a
///   fresh instance (and multiple instances can coexist), plus the cheap
///   per-call use cases they depend on.
void setupInjectionContainer() {
  getIt.registerLazySingleton(() => AppBloc());
  getIt.registerLazySingleton(
    () => GalleryBloc(
      encryptUseCase: getIt(),
      decryptUseCase: getIt(),
      appBloc: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => HomepageBloc(appRepository: getIt(), folderStreamer: getIt()),
  );
  getIt.registerLazySingleton(
    () => DecryptJobManager(decryptUseCase: getIt(), appBloc: getIt()),
  );
  getIt.registerLazySingleton(() => PurchaseBloc(purchaseRepository: getIt()));
  getIt.registerFactory(
    () => EncryptionPageBloc(
      appBloc: getIt(),
      galleryBloc: getIt(),
      purchaseBloc: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ArchivePageBloc(
      appBloc: getIt(),
      purchaseBloc: getIt(),
      decryptJobManager: getIt(),
      galleryReaderUseCase: getIt(),
      imageDeleterUseCase: getIt(),
      imageSaverUseCase: getIt(),
      createFolderUseCase: getIt(),
      renameFolderUseCase: getIt(),
      deleteFolderUseCase: getIt(),
      moveImagesUseCase: getIt(),
    ),
  );
  getIt.registerFactory(
    () => EncryptedImagePageBloc(
      appBloc: getIt(),
      galleryBloc: getIt(),
      imageSaverUseCase: getIt(),
      imageRenamerUseCase: getIt(),
    ),
  );

  getIt.registerLazySingleton<EncryptImageUseCase>(
    () => EncryptImageUseCase(imageRepo: getIt(), storageRepo: getIt()),
  );
  getIt.registerLazySingleton<DecryptImageUseCase>(
    () => DecryptImageUseCase(imageRepo: getIt(), storageRepo: getIt()),
  );
  getIt.registerLazySingleton<GalleryReaderUseCase>(
    () => GalleryReaderUseCase(imageRepo: getIt(), storageRepo: getIt()),
  );
  getIt.registerLazySingleton<ImageDeleterUseCase>(
    () => ImageDeleterUseCase(storageRepo: getIt()),
  );
  getIt.registerFactory(() => AppFolderStreamerUseCase(appRepository: getIt()));
  getIt.registerFactory(() => ImageSaverUseCase(storageRepo: getIt()));
  getIt.registerFactory(() => ImageRenamerUseCase(storageRepo: getIt()));
  getIt.registerFactory(() => CreateFolderUseCase(storageRepo: getIt()));
  getIt.registerFactory(() => RenameFolderUseCase(storageRepo: getIt()));
  getIt.registerFactory(() => DeleteFolderUseCase(storageRepo: getIt()));
  getIt.registerFactory(() => MoveImagesUseCase(storageRepo: getIt()));

  getIt.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl());
  getIt.registerLazySingleton<ImageProcessingRepository>(
    () => ImageProcessingRepositoryImpl(),
  );
  getIt.registerFactory<AppRepository>(() => AppRepositoryImpl());

  // Must be a singleton: it holds the one live subscription to the store's
  // purchase stream and the cached entitlement every gate reads.
  getIt.registerLazySingleton(() => PurchaseDatasource());
  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(datasource: getIt(), preferences: prefs),
  );

  getIt.registerLazySingleton(() => ThemeNotifier());
  getIt.registerLazySingleton(() => WhatsNewService(prefs));
}
