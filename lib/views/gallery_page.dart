import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.galleryViewModel});

  final GalleryViewModel galleryViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Gallery')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          galleryViewModel.pickFiles();
        },
        child: const Icon(Icons.download_rounded),
      ),
      body: ChangeNotifierProvider(
        create: (context) => galleryViewModel..loadNextPage(),
        child: Consumer<GalleryViewModel>(
          builder: (context, gallery, _) {
            return GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: gallery.images.length + (gallery.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= gallery.images.length) {
                  return Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                final image = gallery.images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(image.file, fit: BoxFit.cover),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
