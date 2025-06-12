import 'dart:typed_data';

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
                ? _decodedImage(bytes)
                : Image.file(image.file, fit: BoxFit.cover),
      ),
    );
  }

  Widget _decodedImage(Uint8List bytes) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(bytes, fit: BoxFit.cover),

        Align(
          alignment: Alignment.topRight,
          child: Transform.rotate(
            angle: 3.14 / 4,
            child: Transform.translate(
              offset: const Offset(40, -30),
              child: Container(
                width: double.maxFinite,
                height: 24,
                color: context.colorScheme.primaryContainer.withValues(
                  alpha: 0.6,
                ),
                child: Transform.rotate(
                  angle: -3.14 / 4,
                  child: Icon(
                    Icons.lock_open_rounded,
                    color: context.colorScheme.onPrimaryContainer,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
