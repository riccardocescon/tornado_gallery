part of '../encryption_page.dart';

class _OptionsCard extends StatelessWidget {
  const _OptionsCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Options", style: context.textTheme.titleMedium),
            Text(
              "optional",
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: AppStyle.cardBorderRadius,
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _OptionItem(
                icon: Icons.remove_red_eye_outlined,
                title: "Gallery visibility",
                subtitle:
                    "Allow encrypted images to be saved in public gallery",
                trailing: BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
                  buildWhen:
                      (previous, current) => current.maybeMap(
                        settingsUi: (state) => true,
                        orElse: () => false,
                      ),
                  builder: (context, state) {
                    final galleryVisibility = state.maybeMap(
                      settingsUi: (state) => state.galleryVisible,
                      orElse: () => false,
                    );
                    return Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: galleryVisibility,
                        onChanged: (_) {
                          context.read<EncryptionPageBloc>().add(
                            const EncryptionPageEvent.toggleGalleryVisibility(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _divisor(context),
              _OutputFolderOption(),
              _divisor(context),
              _OptionItem(
                icon: Icons.image_outlined,
                title: "Override image",
                subtitle:
                    "Allow ovverride in case of existing image with the same name in output folder",
                trailing: BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
                  buildWhen:
                      (previous, current) => current.maybeMap(
                        settingsUi: (state) => true,
                        orElse: () => false,
                      ),
                  builder: (context, state) {
                    final galleryVisibility = state.maybeMap(
                      settingsUi: (state) => state.overrideImage,
                      orElse: () => false,
                    );
                    return Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: galleryVisibility,
                        onChanged: (_) {
                          context.read<EncryptionPageBloc>().add(
                            const EncryptionPageEvent.toggleOverrideImage(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _divisor(context),
              _OptionItem(
                icon: Icons.delete_outline_rounded,
                title: "Delete Originals",
                subtitle: "Permanently delete original images after encryption",
                trailing: BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
                  buildWhen:
                      (previous, current) => current.maybeMap(
                        settingsUi: (state) => true,
                        orElse: () => false,
                      ),
                  builder: (context, state) {
                    final deleteOriginals = state.maybeMap(
                      settingsUi: (state) => state.deleteOriginals,
                      orElse: () => false,
                    );
                    return Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: deleteOriginals,
                        onChanged: (_) {
                          context.read<EncryptionPageBloc>().add(
                            const EncryptionPageEvent.toggleDeleteOriginals(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divisor(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: context.colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }
}
