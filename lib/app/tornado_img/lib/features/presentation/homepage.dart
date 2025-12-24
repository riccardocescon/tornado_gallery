import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/app_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_viewmodel.dart';
import 'package:tornado_img_app/main.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tornado Image'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              packageInfo.version,
              style: context.textTheme.labelLarge,
            ),
          ),
        ],
      ),
      body: Consumer<HomepageViewmodel>(
        builder: (context, vm, _) {
          return GridView.builder(
            itemCount: 2,
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                if (vm.galleryViewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return _folder(
                  context,
                  'Local Gallery',
                  vm.galleryViewModel.images,
                  () =>
                      context.pushNamed('gallery', extra: vm.galleryViewModel),
                );
              }

              if (index == 1) {
                if (vm.encryptedGalleryViewModel.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return _folder(
                  context,
                  'Encrypted Gallery',
                  vm.encryptedGalleryViewModel.images,
                  () => context.pushNamed(
                    'encrypted_gallery',
                    extra: vm.encryptedGalleryViewModel,
                  ),
                );
              }

              return SizedBox.shrink(); // Fallback for unexpected index
            },
          );
        },
      ),
    );
  }

  Widget _folder(
    BuildContext context,
    String title,
    List<AppImage> images,
    VoidCallback onTap,
  ) {
    final previewImages = math.min(images.length, 3);

    final imagesPreview = List.generate(previewImages, (index) {
      final image = images[index];
      final reverseIndex = previewImages - 1 - index;
      final offset = reverseIndex * 10.0;
      return Transform.translate(
        offset: Offset(offset, -offset) + Offset(-10, 10),
        child: Opacity(
          opacity: 1 - (reverseIndex * 0.4),
          child: _image(image.file),
        ),
      );
    });

    return GestureDetector(
      onTap: images.isEmpty ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(16).copyWith(bottom: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: AppStyle.borderRadius,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (previewImages > 0) ...[
              Expanded(child: Stack(children: imagesPreview)),
              SizedBox(height: 16),
            ],
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(File file) {
    return ClipRRect(
      borderRadius: AppStyle.borderRadius,
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }
}
