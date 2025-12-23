import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img_app/features/viewmodels/encrypted_gallery_viewmodel.dart';
import 'package:tornado_img_app/features/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';
import 'package:tornado_img_app/features/views/encrypted_page/encrypted_gallery_page.dart';
import 'package:tornado_img_app/features/views/gallery_page/gallery_page.dart';
import 'package:tornado_img_app/features/views/homepage.dart';
import 'package:tornado_img_app/features/views/test_page.dart';

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
      path: '/',
      name: 'home',
      builder: (context, state) {
        return const Homepage();
      },
      routes: [
        GoRoute(
          path: 'gallery',
          name: 'gallery',
          builder: (context, state) {
            final galleryViewModel = state.extra as GalleryViewModel;
            return ChangeNotifierProvider.value(
              value: galleryViewModel,
              child: GalleryPage(),
            );
          },
        ),
        GoRoute(
          path: 'encrypted_gallery',
          name: 'encrypted_gallery',
          builder: (context, state) {
            final encryptedGallery = state.extra as EncryptedGalleryViewModel;
            return ChangeNotifierProvider.value(
              value: encryptedGallery,
              child: EncryptedGalleryPage(),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/encrypted_gallery/:relativePath',
      builder: (context, state) {
        final root = state.pathParameters['relativePath']!;
        return ChangeNotifierProvider(
          create: (_) => EncryptedGalleryViewModel(root: root)..init(),
          child: EncryptedGalleryPage(),
        );
      },
    ),
  ],
);
