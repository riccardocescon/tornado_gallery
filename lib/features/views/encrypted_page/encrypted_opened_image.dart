import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img/core/dialogs/decrypt_dialog.dart';
import 'package:tornado_img/extentions.dart';
import 'package:tornado_img/features/models/encrypted/encrypted_image.dart';

class EncryptedOpenedImage extends StatefulWidget {
  const EncryptedOpenedImage({
    super.key,
    required this.image,
    required this.onDelete,
    required this.onDecrypt,
  });

  final EncryptedImage image;
  final VoidCallback onDelete;
  final void Function(String password) onDecrypt;

  @override
  State<EncryptedOpenedImage> createState() => _EncryptedOpenedImageState();
}

class _EncryptedOpenedImageState extends State<EncryptedOpenedImage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        color: context.colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child:
                  widget.image.decryptedBytes != null
                      ? Image.memory(
                        widget.image.decryptedBytes!,
                        fit: BoxFit.contain,
                      )
                      : Image.file(widget.image.file, fit: BoxFit.contain),
            ),
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
    final isDecrypted = widget.image.decryptedBytes != null;

    return IconButton(
      icon: Icon(
        isDecrypted ? Icons.restore : Icons.remove_red_eye_rounded,
        color: Colors.white,
      ),
      onPressed: () {
        if (isDecrypted) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) {
              return AlertDialog(
                title: const Text('Rollback Decryption'),
                content: const Text(
                  'Are you sure you want to rollback the decryption? This will cancel any decryption made.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop();
                      setState(() {
                        widget.image.decryptedBytes = null;
                      });
                    },
                    child: const Text('Rollback'),
                  ),
                ],
              );
            },
          );
        } else {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return DecryptDialog(onDecrypt: widget.onDecrypt);
            },
          );
        }
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
                TextButton(
                  onPressed: widget.onDelete,
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
