import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/core/dialogs/encrypt_dialog.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class GalleryOpenedImage extends StatelessWidget {
  const GalleryOpenedImage({
    super.key,
    required this.image,
    required this.onDelete,
    required this.onEncrypt,
  });

  final GalleryImage image;
  final VoidCallback onDelete;
  final void Function(String password, String? path) onEncrypt;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        color: context.colorScheme.surface,
        child: Column(
          children: [
            Expanded(child: Image.file(image.file, fit: BoxFit.contain)),
            Container(
              color: context.colorScheme.surface,
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_encryptButton(context), _deleteButton(context)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encryptButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.enhanced_encryption_rounded, color: Colors.white),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return EncryptDialog(image: image, onEncrypt: onEncrypt);
          },
        );
      },
    );
  }

  Widget _deleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return AlertDialog(
              title: const Text('Delete Image'),
              content: const Text(
                'Are you sure you want to delete this image?',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(onPressed: onDelete, child: const Text('Delete')),
              ],
            );
          },
        );
      },
    );
  }
}
