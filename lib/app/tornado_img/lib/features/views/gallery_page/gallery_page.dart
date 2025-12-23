import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/models/gallery_image.dart';
import 'package:tornado_img_app/features/viewmodels/gallery_viewmodel/gallery_viewmodel.dart';
import 'package:tornado_img_app/features/views/gallery_page/gallery_opened_image.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryImage? _selectedImage;

  GalleryViewModel get galleryViewModel =>
      Provider.of<GalleryViewModel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _selectedImage = null;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Local Gallery')),
        floatingActionButton:
            _selectedImage != null
                ? null
                : FloatingActionButton(
                  onPressed: () {
                    galleryViewModel.pickFiles();
                  },
                  child: const Icon(Icons.download_rounded),
                ),
        body: Stack(
          children: [
            _gallery(),
            if (_selectedImage != null)
              GalleryOpenedImage(
                image: _selectedImage!,
                onEncrypt: (password, path) {
                  galleryViewModel
                      .encryptImage(
                        image: _selectedImage!,
                        password: password,
                        path: path,
                      )
                      .then((error) {
                        if (!context.mounted) return;

                        if (error == null) {
                          context.pop();
                          context.showSuccessSnackbar(
                            'Image encrypted successfully!',
                          );
                        } else {
                          context.showErrorSnackbar(error);
                        }
                      });
                },
                onDelete: () {
                  galleryViewModel.deleteImage(_selectedImage!);
                  context.pop();
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _gallery() {
    return Consumer<GalleryViewModel>(
      builder: (context, gallery, _) {
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: gallery.images.length,
          itemBuilder: (context, index) {
            if (index >= gallery.images.length) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            final image = gallery.images[index];
            return _image(image);
          },
        );
      },
    );
  }

  Widget _image(GalleryImage image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = image;
        });
      },
      child: ClipRRect(
        borderRadius: AppStyle.borderRadius,
        child: Image.file(image.file, fit: BoxFit.cover),
      ),
    );
  }
}
