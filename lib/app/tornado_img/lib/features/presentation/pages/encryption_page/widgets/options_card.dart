part of '../encryption_page.dart';

class _OptionsCard extends StatelessWidget {
  const _OptionsCard();

  @override
  Widget build(BuildContext context) {
    // v1 saves gallery-visible videos to the public album on Android only, so
    // say so rather than letting the toggle promise something it won't do.
    final iosVideoCaveat =
        Platform.isIOS &&
        context.read<EncryptionPageBloc>().images.any((image) => image.isVideo);

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
        AppCard(
          child: Column(
            children: [
              OptionItem.trailing(
                icon: Icons.remove_red_eye_outlined,
                title: "Gallery visibility",
                subtitle:
                    iosVideoCaveat
                        ? "Allow encrypted images to be saved in public gallery. On iOS videos are always saved privately."
                        : "Allow encrypted images to be saved in public gallery",
                trailing: _SettingToggle(
                  selector: (settings) => settings.galleryVisible,
                  event: const EncryptionPageEvent.toggleGalleryVisibility(),
                ),
              ),
              _divisor(context),
              _OutputFolderOption(),
              _divisor(context),
              OptionItem.trailing(
                icon: Icons.image_outlined,
                title: "Override image",
                subtitle:
                    "Allow override in case of existing image with the same name in output folder",
                trailing: _SettingToggle(
                  selector: (settings) => settings.overrideImage,
                  event: const EncryptionPageEvent.toggleOverrideImage(),
                ),
              ),
              _divisor(context),
              OptionItem.trailing(
                icon: Icons.delete_outline_rounded,
                title: "Delete Originals",
                subtitle: "Permanently delete original images after encryption",
                trailing: _SettingToggle(
                  selector: (settings) => settings.deleteOriginals,
                  event: const EncryptionPageEvent.toggleDeleteOriginals(),
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

/// A single settings toggle wired to [EncryptionPageBloc].
///
/// [selector] reads the current value from [EncryptionSettings]; [event] is
/// dispatched when the switch is flipped. Replaces the three identical
/// gallery-visibility / override-image / delete-originals switches.
class _SettingToggle extends StatelessWidget {
  const _SettingToggle({required this.selector, required this.event});

  final bool Function(EncryptionSettings settings) selector;
  final EncryptionPageEvent event;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen: (previous, current) =>
          current.maybeMap(settingsUi: (state) => true, orElse: () => false),
      builder: (context, state) {
        final value = state.maybeMap(
          settingsUi: (state) => selector(state.settings),
          orElse: () => false,
        );
        return Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: (_) =>
                context.read<EncryptionPageBloc>().add(event),
          ),
        );
      },
    );
  }
}
