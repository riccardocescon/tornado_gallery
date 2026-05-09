import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/presentation/widgets/update_app_card.dart';
import 'package:tornado_img_app/core/utils/constants.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/archiving_state.dart';
import 'package:tornado_img_app/features/presentation/bloc/homepage_bloc/homepage_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/contained_item.dart';
import 'package:tornado_img_app/features/presentation/widgets/loading_container.dart';
import 'package:tornado_img_app/features/presentation/widgets/page_title.dart';
import 'package:tornado_img_app/injection_container.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

part 'widgets/action_card.dart';
part 'widgets/archive_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    context.read<HomepageBloc>().add(const HomepageEvent.setup());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomepageBloc, HomepageState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          failure: (message) {
            context.showErrorSnackbar("Failed to load images");
          },
          galleryImages: (galleryImages) {
            if (galleryImages.isEmpty) {
              context.showSnackbar("No images selected");
              return;
            }

            context.push("/encryption", extra: galleryImages);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              const SizedBox(height: 2),
              Column(
                spacing: 8,
                children: [
                  PageTitle(
                    title: "Tornado Gallery",
                    subtitle:
                        "Visually encrypting your images for full privacy",
                    icon: Icons.lock_rounded,
                  ),
                  UpdateAppCard(),
                ],
              ),
              _actions(),
              const _ArchiveState(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _actions() {
    return IntrinsicHeight(
      child: Row(
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
              onPressed: () async {
                final permissionState =
                    await PhotoManager.requestPermissionExtend();
                if (!mounted) return;
                if (!permissionState.isAuth && !permissionState.isLimited) {
                  context.showSnackbar(
                    "Permission to access photos was denied",
                  );
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
              onPressed: () {
                context.read<HomepageBloc>().add(
                  HomepageEvent.setScreen(page: Pages.archive),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
