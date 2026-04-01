import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_icon.dart';
import 'package:tornado_img_app/features/presentation/widgets/password_form_field.dart';

part 'widgets/image.dart';
part 'widgets/info.dart';

class EncryptedImagePage extends StatelessWidget {
  const EncryptedImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Image')),
      body: BlocBuilder<EncryptedImagePageBloc, EncryptedImagePageState>(
        builder: (context, state) {
          return state.maybeMap(
            ui: (value) {
              final image = value.image;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  children: [
                    SizedBox(
                      height: 300,
                      child: BlocBuilder<
                        EncryptedImagePageBloc,
                        EncryptedImagePageState
                      >(
                        buildWhen:
                            (previous, current) => current.maybeMap(
                              ui: (value) => true,
                              orElse: () => false,
                            ),
                        builder: (context, state) {
                          final showImage = state.maybeMap(
                            ui: (value) => value.image,
                            orElse: () => null,
                          );

                          if (showImage == null) {
                            return Container(
                              height: 300,
                              width: 200,
                              color: Colors.red,
                            );
                          }

                          return _Image(image: showImage);
                        },
                      ),
                    ),
                    _titleRow(context, image),
                    _Info(image: image),
                  ],
                ),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _titleRow(BuildContext context, GalleryImage image) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 8,
            children: [
              ContainedIcon(icon: Icons.lock_rounded),
              Text(image.name, style: context.textTheme.headlineSmall),
            ],
          ),
        ),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: context.appColors.softBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: AppStyle.detailsBorderRadius,
            ),
          ),
          child: Row(
            spacing: 4,
            children: [
              Icon(Icons.lock_rounded, color: context.colorScheme.onSurface),
              Text('Decrypt', style: context.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
