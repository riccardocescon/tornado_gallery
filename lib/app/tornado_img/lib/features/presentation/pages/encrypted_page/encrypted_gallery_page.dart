import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/dialogs/create_folder_dialog.dart';
import 'package:tornado_img_app/core/dialogs/decrypt_dialog.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_gallery_viewmodel.dart';
import 'package:tornado_img_app/features/presentation/pages/encrypted_page/encrypted_opened_image.dart';

part 'gallery_fab.dart';

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
        appBar: AppBar(
          title: Text(
            encryptedGalleryViewModel.root == null
                ? 'Local Gallery'
                : encryptedGalleryViewModel.root!
                    .split('/')
                    .reversed
                    .take(3)
                    .toList()
                    .reversed
                    .join('/'),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, _, __) {
                    return DecryptDialog(
                      onDecrypt: (password) {
                        encryptedGalleryViewModel.decryptEntireFolder(
                          password: password,
                        );
                        context.pop();
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.lock_open_rounded, size: 20),
            ),
            if (encryptedGalleryViewModel.root != null)
              IconButton(
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return AlertDialog(
                        title: Text(
                          'Delete Folder',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.error,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Are you sure you want to delete this folder and all its files and subfolders? This action cannot be undone.',
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Folder: ${encryptedGalleryViewModel.root}',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: context.colorScheme.primary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Cancel',
                              style: context.textTheme.bodySmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              encryptedGalleryViewModel.deleteFolder();
                              context.pop();
                              context.pop();
                            },
                            child: Text(
                              'Delete',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: context.colorScheme.error,
                  size: 20,
                ),
              ),
          ],
        ),
        floatingActionButton: _GalleryFAB(
          encryptedGalleryViewModel: encryptedGalleryViewModel,
        ),
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
          itemCount: gallery.entities.length,
          itemBuilder: (context, index) {
            if (index >= gallery.entities.length) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            final entity = gallery.entities[index];
            if (entity.isImage) return _image(entity.asImage);
            return _folder(entity.asFolder);
          },
        );
      },
    );
  }

  Widget _folder(EncryptedFolder folder) {
    return FilledButton(
      onPressed: () {
        // setState(() {
        //   _selectedImage = image;
        // });
        context.push('/encrypted_gallery/${folder.encryptedRelativePath}');
      },
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: AppStyle.borderRadius),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.folder_rounded,
            color: context.colorScheme.primary,
            size: 48,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                folder.name,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(EncryptedImage image) {
    final bytes = image.decryptedBytes;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
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
        ),
        if (image.isDecrypting)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.primary,
              ),
            ),
          ),
      ],
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
