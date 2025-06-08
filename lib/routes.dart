import 'package:go_router/go_router.dart';
import 'package:tornado_img/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';
import 'package:tornado_img/views/gallery_page.dart';
import 'package:tornado_img/views/homepage.dart';

GoRouter routes = GoRouter(
  initialLocation: '/',
  routes: [
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
            return GalleryPage(galleryViewModel: galleryViewModel.copyWith());
          },
        ),
      ],
    ),
  ],
);
