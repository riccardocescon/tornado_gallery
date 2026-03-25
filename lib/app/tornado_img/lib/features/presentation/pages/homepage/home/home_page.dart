import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_icon.dart';
import 'package:tornado_img_app/features/presentation/widgets/loading_container.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'widgets/action_card.dart';
part 'widgets/archive_state.dart';
part 'widgets/info_cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    context.read<HomepageBloc>().add(const HomepageEvent.refresh());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomepageBloc, HomepageState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          galleryImages: (galleryImages) {
            if (galleryImages.isEmpty) {
              context.showSnackbar("No images selected");
              return;
            }

            context.push("/encryption", extra: galleryImages);
          },
        );
      },
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            const SizedBox(height: 2),
            _title(),
            _actions(),
            const _ArchiveState(),
            const _InfoCards(),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 12,
          children: [
            ContainedIcon(icon: Icons.lock_rounded),
            Text(
              "Tornado Gallery",
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          "Visually encrypted your images for full privacy",
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _actions() {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.image_rounded,
            title: "Select Photo",
            subtitle: "Select from your gallery",
            buttonText: "Open gallery",
            buttonIcon: Icons.image_rounded,
            darker: true,
            onPressed:
                () async {
              final permissionState =
                  await PhotoManager.requestPermissionExtend();
              if (!mounted) return;
              if (!permissionState.isAuth && !permissionState.isLimited) {
                context.showSnackbar("Permission to access photos was denied");
                return;
              }

              final assets = await AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  requestType: RequestType.image,
                  maxAssets: 100,
                ),
              );
              if (!mounted) return;
              if (assets?.isEmpty ?? true) {
                context.showSnackbar("No images selected");
                return;
              }

              context.read<HomepageBloc>().add(
                HomepageEvent.galleryAssetsSelected(imagesSelected: assets!),
              );
            },
          ),
        ),
        Expanded(
          child: _ActionCard(
            icon: Icons.lock_rounded,
            title: "My encrypted photos",
            subtitle: "View and decrypt",
            buttonText: "Open archive",
            buttonIcon: Icons.lock_rounded,
            darker: false,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
