import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img/app_style.dart';
import 'package:tornado_img/extentions.dart';
import 'package:tornado_img/features/models/encrypted_image.dart';
import 'package:tornado_img/features/viewmodels/encrypted_gallery_viewmodel.dart';
import 'package:tornado_img/features/views/encrypted_page/encrypted_opened_image.dart';

class EncryptedGalleryPage extends StatefulWidget {
  const EncryptedGalleryPage({super.key});

  @override
  State<EncryptedGalleryPage> createState() => _EncryptedGalleryPageState();
}

class _EncryptedGalleryPageState extends State<EncryptedGalleryPage> {
  EncryptedImage? _selectedImage;

  EncryptedGalleryViewModel get encryptedGalleryViewModel =>
      Provider.of<EncryptedGalleryViewModel>(context, listen: false);

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

        body: Stack(
          children: [
            _gallery(),
            if (_selectedImage != null)
              EncryptedOpenedImage(
                image: _selectedImage!,
                onDecrypt: (password) {
                  encryptedGalleryViewModel
                      .decryptImage(image: _selectedImage!, password: password)
                      .then((decryptedBytes) {
                        if (!context.mounted) return;

                        if (decryptedBytes == null) {
                          context.showErrorSnackbar('Failed to decrypt image');
                        } else {
                          context.pop();
                          setState(() {
                            _selectedImage?.decryptedBytes = decryptedBytes;
                          });
                        }
                      });
                },
                onDelete: () {
                  encryptedGalleryViewModel.deleteImage(_selectedImage!);
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
    return Consumer<EncryptedGalleryViewModel>(
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

  Widget _image(EncryptedImage image) {
    final bytes = image.decryptedBytes;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImage = image;
        });
      },
      child: ClipRRect(
        borderRadius: AppStyle.borderRadius,
        child:
            bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : Image.file(image.file, fit: BoxFit.cover),
      ),
    );
  }
}
