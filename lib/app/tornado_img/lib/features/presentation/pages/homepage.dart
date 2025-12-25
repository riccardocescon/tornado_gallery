import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/app_image.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/main.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    context.read<HomepageBloc>().add(const HomepageEvent.setup());
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<HomepageBloc>().add(const HomepageEvent.refresh());
  }

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
      body: BlocBuilder<HomepageBloc, HomepageState>(
        builder: (context, state) {
          return GridView.builder(
            itemCount: 2,
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return state.maybeMap(
                loaded: (value) {
                  if (index == 0) {
                    final images = value.images;
                    if (images == null) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return _folder(
                      'Local Gallery',
                      images,
                      () => context.pushNamed('gallery'),
                    );
                  }

                  if (index == 1) {
                    final encryptedImages = value.encryptedImages;
                    if (encryptedImages == null) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return _encryptedFolder(
                      'Encrypted Gallery',
                      encryptedImages,
                      () => context.pushNamed('encrypted_gallery'),
                    );
                  }

                  return SizedBox.shrink(); // Fallback for unexpected index
                },
                orElse: () => SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _folder(String title, List<AppImage> images, VoidCallback onTap) {
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

  Widget _encryptedFolder(
    String title,
    List<EncryptedEntity> images,
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
          child: image.isImage ? _image(image.asImage.file) : _folderItem(),
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

  Widget _folderItem() {
    return ClipRRect(
      borderRadius: AppStyle.borderRadius,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: context.colorScheme.primary.withValues(alpha: 0.4),
          child: Center(
            child: Icon(
              Icons.folder,
              size: 48,
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
