part of '../archive_page.dart';

class _ImportImagesBottomSheet extends StatefulWidget {
  const _ImportImagesBottomSheet({required this.assets});

  final List<AssetEntity> assets;

  @override
  State<_ImportImagesBottomSheet> createState() =>
      __ImportImagesBottomSheetState();
}

class __ImportImagesBottomSheetState extends State<_ImportImagesBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      BottomSheet.createAnimationController(this);

  final cachedImages = <String, Image>{};

  bool saveToAppFolder = true;
  bool saveToGallery = false;

  @override
  void initState() {
    for (final asset in widget.assets) {
      asset.thumbnailDataWithSize(ThumbnailSize(200, 200)).then((bytes) {
        if (bytes != null) {
          setState(() {
            cachedImages[asset.id] = Image.memory(bytes, fit: BoxFit.cover);
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      animationController: _animationController,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Import images", style: context.textTheme.titleMedium),
              SizedBox(
                height: 200,
                child: CarouselView.weightedBuilder(
                  flexWeights: [3, 2, 1],
                  itemSnapping: true,
                  itemCount: cachedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: AppStyle.cardBorderRadius,
                        child: cachedImages.values.elementAt(index),
                      ),
                    );
                  },
                ),
              ),
              _option(
                icon: Icons.folder_rounded,
                title: "Save to App folder",
                subtitle: "Private folder, only accessible by the app",
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: saveToAppFolder,
                    onChanged:
                        (val) => setState(() {
                          saveToAppFolder = val;
                          saveToGallery = !val;
                        }),
                  ),
                ),
              ),
              _option(
                icon: Icons.photo_library_outlined,
                title: "Save to Gallery",
                subtitle: "Public folder, accessible on the gallery",
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: saveToGallery,
                    onChanged:
                        (val) => setState(() {
                          saveToGallery = val;
                          saveToAppFolder = !val;
                        }),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ArchivePageBloc>().add(
                    ArchivePageEvent.importImages(
                      assets: widget.assets,
                      saveToAppFolder: saveToAppFolder,
                      saveToGallery: saveToGallery,
                    ),
                  );
                  context.pop();
                },
                child: const Text("Import all"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _option({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, color: context.colorScheme.primary),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.titleSmall),
              Text(
                subtitle,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
