import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/dialogs/create_folder_dialog.dart';
import 'package:tornado_img_app/core/dialogs/decrypt_dialog.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_gallery_page_bloc/encrypted_gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/encrypted_page/encrypted_opened_image.dart';

part 'gallery_fab.dart';

class EncryptedGalleryPage extends StatefulWidget {
  const EncryptedGalleryPage({super.key});

  @override
  State<EncryptedGalleryPage> createState() => _EncryptedGalleryPageState();
}

class _EncryptedGalleryPageState extends State<EncryptedGalleryPage> {
  EncryptedImage? _selectedImage;

  @override
  void initState() {
    context.read<EncrpytedGalleryPageBloc>().add(
      const EncrpytedGalleryPageEvent.setup(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final root = context.read<EncrpytedGalleryPageBloc>().root;

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
            root == null
                ? 'Local Gallery'
                : root.split('/').reversed.take(3).toList().reversed.join('/'),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (dialogContext, _, __) {
                    return DecryptDialog(
                      onDecrypt: (password) {
                        context.read<EncrpytedGalleryPageBloc>().add(
                          EncrpytedGalleryPageEvent.decryptFolder(
                            password: password,
                          ),
                        );
                            
                        dialogContext.pop();
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.lock_open_rounded, size: 20),
            ),
            if (root != null)
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
                              'Folder: $root',
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
                              context.read<EncrpytedGalleryPageBloc>().add(
                                EncrpytedGalleryPageEvent.deleteFolder(),
                              );
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
        floatingActionButton: _GalleryFAB(),
        body: BlocListener<EncrpytedGalleryPageBloc, EncrpytedGalleryPageState>(
          listenWhen:
              (previous, current) => current.maybeMap(
                decrypted:
                    (_) => previous.maybeMap(
                      loading: (_) => true,
                      orElse: () => false,
                    ),
                failure: (_) => true,
                orElse: () => false,
              ),
          listener: (context, state) {
            state.maybeMap(
              decrypted: (value) {
                context.pop();
                setState(() {
                  _selectedImage?.decryptedBytes = value.data;
                });
              },
              failure: (value) {
                context.showErrorSnackbar(value.message);
              },
              orElse: () {},
            );
          },
          child: Stack(
            children: [
              _gallery(),
              if (_selectedImage != null)
                EncryptedOpenedImage(
                  image: _selectedImage!,
                  onDecrypt: (password) {
                    context.read<EncrpytedGalleryPageBloc>().add(
                      EncrpytedGalleryPageEvent.decryptImage(
                        image: _selectedImage!,
                        password: password,
                        path: null,
                      ),
                    );
                  },
                  onDelete: () {
                    context.read<EncrpytedGalleryPageBloc>().add(
                      EncrpytedGalleryPageEvent.deleteImage(
                        image: _selectedImage!,
                      ),
                    );
                    context.pop();
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    return BlocBuilder<EncrpytedGalleryPageBloc, EncrpytedGalleryPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(loaded: (_) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          loaded: (value) {
            return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
              itemCount: value.images.length,
          itemBuilder: (context, index) {
                if (index >= value.images.length) {
              return Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

                final entity = value.images[index];
            if (entity.isImage) return _image(entity.asImage);
            return _folder(entity.asFolder);
          },
        );
          },
          orElse: () => const SizedBox(),
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
