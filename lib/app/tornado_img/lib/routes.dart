import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/core/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/core/utils/routes.dart' as r;
import 'package:tornado_img_app/features/presentation/bloc/archive_page_bloc/archive_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/app_logger_page/app_logger_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encrypted_image_page/encrypted_image_page.dart';
import 'package:tornado_img_app/features/presentation/pages/encryption_page/encryption_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/archive/archive_page.dart';
import 'package:tornado_img_app/features/presentation/pages/homepage/shell_homepage.dart';
import 'package:tornado_img_app/features/presentation/pages/video_player_page/video_player_page.dart';
import 'package:tornado_img_app/injection_container.dart';

GoRouter routes = GoRouter(
  initialLocation: r.Routes.homePath,
  routes: [
    GoRoute(
      path: r.Routes.loggerPath,
      name: r.Routes.logger,
      builder: (context, state) {
        return const AppLoggerPage();
      },
    ),
    GoRoute(
      path: r.Routes.homePath,
      name: r.Routes.home,
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
          path: r.Routes.encryptionPath,
          name: r.Routes.encryption,
          builder: (context, state) {
            final images = state.extra as List<GalleryImage>;

            return BlocProvider(
              create:
                  (context) =>
                      getIt<EncryptionPageBloc>()
                        ..add(EncryptionPageEvent.setup(images: images)),
              child: EncryptionPage(),
            );
          },
        ),
        GoRoute(
          path: r.Routes.archivePath,
          name: r.Routes.archive,
          builder: (context, state) {
            final bloc = state.extra as ArchivePageBloc;
            return BlocProvider.value(
              value: bloc,
              child: const ArchivePage(),
            );
          },
        ),
        GoRoute(
          path: r.Routes.encryptedImagePagePath,
          name: r.Routes.encryptedImagePage,
          builder: (context, state) {
            final image = state.extra as EncryptedImage;

            return BlocProvider(
              create:
                  (context) =>
                      getIt<EncryptedImagePageBloc>()..add(
                        EncryptedImagePageEvent.setup(
                          imagePath: image.storagePath.file.path,
                        ),
                      ),
              child: EncryptedImagePage(),
            );
          },
        ),
        GoRoute(
          path: r.Routes.videoPlayerPath,
          name: r.Routes.videoPlayer,
          builder: (context, state) {
            return VideoPlayerPage(image: state.extra as EncryptedImage);
          },
        ),
      ],
    ),
  ],
);
