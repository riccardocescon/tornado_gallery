import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/app_logger_page/app_logger_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encrypted_image_page/encrypted_image_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encryption_page/encryption_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/shell_homepage.dart';
import 'package:tornado_img_app/injection_container.dart';

GoRouter routes = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/logger',
      name: 'logger',
      builder: (context, state) {
        return const AppLoggerPage();
      },
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<HomepageBloc>(),
            ),
            BlocProvider(
              lazy: false,
              create:
                  (context) =>
                      getIt<ArchivePageBloc>()..add(ArchivePageEvent.setup()),
            ),
          ],
          child: const ShellHomepage(),
        ); 
      },
      routes: [
        GoRoute(
          path: 'encryption',
          name: 'encryption',
          builder: (context, state) {
            final images = state.extra as dynamic;

            return BlocProvider(
              create:
                  (context) =>
                      getIt<EncryptionPageBloc>()
                        ..add(EncryptionPageEvent.setup(images: images)),
              child: EncrpytionPage(),
            );
          },
        ),
        GoRoute(
          path: 'encrypted_image_page',
          name: 'encrypted_image_page',
          builder: (context, state) {
            final image = state.extra as EncryptedImage;

            return BlocProvider(
              create:
                  (context) =>
                      getIt<EncryptedImagePageBloc>()..add(
                        EncryptedImagePageEvent.setup(
                          imagePath: image.file.path,
                        ),
                      ),
              child: EncryptedImagePage(),
            );
          },
        ),
      ],
    ),
  ],
);
