import 'package:get_it/get_it.dart';
import 'package:tornado_img_app/core/presentation/bloc/encrypted_gallery_bloc/encrypted_gallery_bloc.dart';
import 'package:tornado_img_app/core/presentation/bloc/gallery_bloc/gallery_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';

GetIt getIt = GetIt.instance;

void setupInjectionContainer() {
  getIt.registerLazySingleton(() => GalleryBloc());
  getIt.registerLazySingleton(() => EncryptedGalleryBloc());
  getIt.registerFactory(() => HomepageBloc());
  getIt.registerFactory(() => GalleryPageBloc());
}
