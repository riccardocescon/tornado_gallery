import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_gallery_page_bloc/encrypted_gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/app_logger_page/app_logger_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encrypted_page/encrypted_gallery_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encryption_page/encryption_page.dart';
import 'package:tornado_img_app/features/presentation/pages/gallery_page/gallery_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/shell_homepage.dart';
import 'package:tornado_img_app/features/presentation/pages/test_page.dart';
import 'package:tornado_img_app/injection_container.dart';

GoRouter routes = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/test',
      name: 'test',
      builder: (context, state) {
        return const TestPage();
      },
    ),
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
        return BlocProvider(
          create:
              (context) => getIt<HomepageBloc>()..add(HomepageEvent.setup()),
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
          path: 'gallery',
          name: 'gallery',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => getIt<GalleryPageBloc>(),
              child: GalleryPage(),
            );
          },
        ),
        GoRoute(
          path: 'encrypted_gallery',
          name: 'encrypted_gallery',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => getIt<EncrpytedGalleryPageBloc>(),
              child: const EncryptedGalleryPage(currentRoute: null),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/encrypted_gallery/:relativePath',
      builder: (context, state) {
        final currentRoute = state.pathParameters['relativePath'];
        return BlocProvider(
          create: (context) => getIt<EncrpytedGalleryPageBloc>(),
          child: EncryptedGalleryPage(currentRoute: currentRoute),
        );
      },
    ),
  ],
);
