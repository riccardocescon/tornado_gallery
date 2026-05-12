import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/presentation/pages/fullscreen_image_viewer.dart';
import 'package:tornado_img_app/core/presentation/widgets/option_item.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_image_page_bloc/encrypted_image_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/password_form_field.dart';

part 'widgets/image.dart';
part 'widgets/info.dart';
part 'widgets/actions.dart';
part 'widgets/page_background.dart';

class EncryptedImagePage extends StatelessWidget {
  const EncryptedImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted Image')),
      body: BlocConsumer<EncryptedImagePageBloc, EncryptedImagePageState>(
        listener: (context, state) {
          state.maybeMap(
            imageSaved: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image saved to gallery: ${value.path}'),
                ),
              );
            },
            orElse: () {},
          );
        },
        buildWhen:
            (previous, current) => current.maybeMap(
              ui: (value) => true,
              orElse: () => false,
            ),
        builder: (context, state) {
          return state.maybeMap(
            ui: (value) {
              final image = value.image;

              return Padding(
                padding: const EdgeInsets.all(16).copyWith(bottom: 0),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16,
                    children: [
                      SizedBox(height: 300, child: _Image()),
                      _titleRow(context, image),
                      _Info(image: image),
                      _Actions(),
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
              );
            },
            orElse: () => const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _titleRow(BuildContext context, EncryptedImage image) {
    final isDecrypted = image.decryptInfo != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              ContainedItem.icon(icon: Icons.lock_rounded),
              Expanded(
                child: Text(image.name, style: context.textTheme.headlineSmall),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed:
              isDecrypted
                  ? () {
                    context.read<EncryptedImagePageBloc>().add(
                      const EncryptedImagePageEvent.restore(),
                    );
                  }
                  : null,
          style: FilledButton.styleFrom(
            backgroundColor: context.appColors.softBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: AppStyle.detailsBorderRadius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDecrypted)
                Text(
                  'Tap to restore',
                  style: context.textTheme.labelSmall!.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              Row(
                spacing: 4,
                children: [
                  Icon(
                    isDecrypted ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: context.colorScheme.onSurface,
                  ),
                  Text(
                    isDecrypted ? 'Decrypted' : 'Encrypted',
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
             
            ],
          ),
        ),
      ],
    );
  }
}
