import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_icon.dart';
import 'package:tornado_img_app/features/presentation/widgets/loading_container.dart';

part 'widgets/images_preview_card.dart';
part 'widgets/password_card.dart';
part 'widgets/options_card.dart';
part 'widgets/options/option_item.dart';
part 'widgets/options/output_folder_option.dart';

class EncrpytionPage extends StatelessWidget {
  const EncrpytionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          iconSize: 18,
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Column(
          spacing: 4,
          children: [
            const Text("Encryption Page"),
            Text(
              "Encrypt your images with a password",
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            spacing: 8,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        spacing: 24,
                        children: [
                          const SizedBox(height: 8),
                          _ImagesPreviewCard(),
                          _PasswordCard(),
                          const _OptionsCard(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
                buildWhen:
                    (previous, current) => current.maybeMap(
                      encrypted: (state) => true,
                      encrypting: (state) => true,
                      failure: (state) => true,
                      orElse: () => false,
                    ),
                builder: (context, state) {
                  final isEncrypting = state.maybeMap(
                    encrypting: (state) => true,
                    orElse: () => false,
                  );

                  if (isEncrypting) return SizedBox.shrink();

                  return FilledButton(
                    onPressed:
                        () => context.read<EncryptionPageBloc>().add(
                          const EncryptionPageEvent.encrypt(),
                        ),
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 18),
                        Text(
                          "Encrypt Images",
                          style: context.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
