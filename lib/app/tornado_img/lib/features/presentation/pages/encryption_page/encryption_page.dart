import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/core/utils/gallery_path_provider.dart';
import 'package:tornado_img_app/core/utils/routes.dart';
import 'package:tornado_img_app/core/presentation/pages/fullscreen_image_viewer.dart';
import 'package:tornado_img_app/core/presentation/widgets/option_item.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/core/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/core/domain/entities/encryption_settings.dart';
import 'package:tornado_img_app/core/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encryption_page_bloc/encryption_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/app_card.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/loading_container.dart';
import 'package:tornado_img_app/features/presentation/widgets/password_form_field.dart';
import 'package:tornado_img_app/features/presentation/widgets/pro_widgets.dart';

part 'widgets/images_preview_card.dart';
part 'widgets/images_preview/single_image_layout.dart';
part 'widgets/images_preview/multi_images_layout.dart';
part 'widgets/password_card.dart';
part 'widgets/options_card.dart';
part 'widgets/options/output_folder_option.dart';
part 'widgets/archiving_state_card.dart';
part 'widgets/skipped_images_dialog.dart';

class EncryptionPage extends StatelessWidget {
  const EncryptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EncryptionPageBloc, EncryptionPageState>(
      listener: (context, state) {
        state.maybeMap(
          encrypting: (value) {
            final archivingState = value.archivingState;
            if (archivingState == null) return;

            final completed = archivingState.progress;
            if (completed != archivingState.totalImages) return;
            if (archivingState.skippedImages.isEmpty) return;

            showDialog(
              context: context,
              builder: (context) {
                return _SkippedImagesDialog(
                  skippedImages: archivingState.skippedImages,
                );
              },
            );
          },
          // The button is already disabled in this case; this only fires if the
          // archive grew past the cap while this page was open.
          limitReached: (_) => context.pushNamed(Routes.pro),
          failure: (value) {
            context.showErrorSnackbar("Encryption failed: ${value.message}");
          },
          orElse: () {},
        );
      },
      child: Scaffold(
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
                            BlocBuilder<
                              EncryptionPageBloc,
                              EncryptionPageState
                            >(
                              buildWhen:
                                  (previous, current) => current.maybeMap(
                                    encrypting: (state) => true,
                                    encrypted: (state) => true,
                                    ui:
                                        (state) => previous.maybeMap(
                                          encrypted: (state) => true,
                                          orElse: () => false,
                                        ),
                                    failure: (state) => true,
                                    orElse: () => false,
                                  ),
                              builder: (context, state) {
                                final encryptingdata = state.maybeMap(
                                  encrypting: (state) => state.archivingState,
                                  orElse: () => null,
                                );
                                if (encryptingdata == null) {
                                  return _PasswordCard(
                                    imagesSize:
                                        context
                                            .watch<EncryptionPageBloc>()
                                            .images
                                            .length,
                                  );
                                }

                                return _ArchivingStateCard(
                                  archivingState: encryptingdata,
                                );
                              },
                            ),
                            const _OptionsCard(),
                            const SizedBox(height: 24),
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
                        limitReached: (state) => true,
                        failure: (state) => true,
                        orElse: () => false,
                      ),
                  builder: (context, state) {
                    final isEncrypting = state.maybeMap(
                      encrypting: (state) => true,
                      orElse: () => false,
                    );

                    // This selection would take a free user past the cap. Offer
                    // Pro instead of letting them press a button that can only
                    // fail.
                    final blocked =
                        context.read<EncryptionPageBloc>().exceedsFreeLimit;

                    return Column(
                      spacing: 12,
                      children: [
                        if (blocked)
                          const ProLimitBanner(
                            message:
                                "You've reached the free limit of "
                                "${Constants.maxEncryptedImages} encrypted images. "
                                "Unlock Pro for unlimited encryptions.",
                          ),
                        FilledButton(
                          onPressed:
                              (isEncrypting || blocked)
                                  ? null
                                  : () => context
                                      .read<EncryptionPageBloc>()
                                      .add(const EncryptionPageEvent.encrypt()),
                          child: Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isEncrypting
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.lock_rounded, size: 18),
                              Text(
                                isEncrypting
                                    ? "Encrypting..."
                                    : "Encrypt Images",
                                style: context.textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
