part of '../archive_page.dart';

class _ImportImagesBottomSheet extends StatefulWidget {
  const _ImportImagesBottomSheet({required this.assets});

  final List<ImportImageAsset> assets;

  @override
  State<_ImportImagesBottomSheet> createState() =>
      __ImportImagesBottomSheetState();
}

class __ImportImagesBottomSheetState extends State<_ImportImagesBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      BottomSheet.createAnimationController(this);

  final cachedImages = <String, Image>{};
  late final Map<String, String> _customNames;
  late final TextEditingController _nameController;
  int _currentIndex = 0;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _customNames = {for (final item in widget.assets) item.asset.id: item.name};
    _nameController = TextEditingController(
      text: _customNames[widget.assets.first.asset.id],
    );
    _nameError = validateFileName(_nameController.text);
    _nameController.addListener(_onNameChanged);

    for (final item in widget.assets) {
      item.asset.thumbnailDataWithSize(ThumbnailSize(200, 200)).then((bytes) {
        if (bytes != null) {
          setState(() {
            cachedImages[item.asset.id] = Image.memory(
              bytes,
              fit: BoxFit.cover,
            );
          });
        }
      });
    }
  }

  void _onNameChanged() {
    final error = validateFileName(_nameController.text);
    _customNames[widget.assets[_currentIndex].asset.id] = _nameController.text;
    if (error != _nameError) {
      setState(() => _nameError = error);
    }
  }

  void _onScrollEnd(int index) {
    if (index == _currentIndex) return;
    _customNames[widget.assets[_currentIndex].asset.id] = _nameController.text;
    setState(() {
      _currentIndex = index;
      _nameController.removeListener(_onNameChanged);
      _nameController.text =
          _customNames[widget.assets[_currentIndex].asset.id] ?? '';
      _nameError = validateFileName(_nameController.text);
      _nameController.addListener(_onNameChanged);
    });
  }

  bool get _canImport =>
      _nameError == null &&
      _customNames.values.every((n) => validateFileName(n) == null);

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool saveToAppFolder = true;
  bool saveToGallery = false;

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
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text("Import images", style: context.textTheme.titleMedium),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / 2;
                    return NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        final index = (notification.metrics.pixels / itemWidth)
                            .round()
                            .clamp(0, widget.assets.length - 1);
                        _onScrollEnd(index);
                        return false;
                      },
                      child: SizedBox(
                        height: 200,
                        child: CarouselView.weightedBuilder(
                          flexWeights: const [3, 2, 1],
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
                    );
                  },
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "File name",
                    border: const OutlineInputBorder(),
                    errorText: _nameError,
                    errorStyle: TextStyle(color: context.colorScheme.error),
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
                  onPressed:
                      _canImport
                          ? () {
                            final updatedAssets =
                                widget.assets.map((item) {
                                  final customName =
                                      _customNames[item.asset.id] ?? item.name;
                                  return ImportImageAsset(
                                    asset: item.asset,
                                    name: customName,
                                  );
                                }).toList();
                            context.read<ArchivePageBloc>().add(
                              ArchivePageEvent.importImages(
                                assets: updatedAssets,
                                saveToAppFolder: saveToAppFolder,
                                saveToGallery: saveToGallery,
                              ),
                            );
                            context.pop();
                          }
                          : null,
                child: const Text("Import all"),
              ),
            ],
          ),
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
