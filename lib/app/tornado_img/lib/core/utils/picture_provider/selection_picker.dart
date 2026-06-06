import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tornado_img_app/core/presentation/pages/fullscreen_image_viewer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TapToSelectPickerDelegate
    extends DefaultAssetPickerBuilderDelegate<DefaultAssetPickerProvider> {
  final ValueNotifier<AssetEntity?> _previewAsset = ValueNotifier(null);

  TapToSelectPickerDelegate({
    required super.provider,
    required super.initialPermission,
    super.gridCount = 3,
    super.themeColor,
    super.locale,
  });

  @override
  void dispose() {
    _previewAsset.dispose();
    super.dispose();
  }

  @override
  Future<void> viewAsset(
    BuildContext context,
    int? index,
    AssetEntity currentAsset,
  ) async {
    if (index == null) {
      return super.viewAsset(context, index, currentAsset);
    }
    final bool isSelected = provider.selectedAssets.contains(currentAsset);
    if (isSelected) {
      provider.unSelectAsset(currentAsset);
    } else {
      if (provider.selectedMaximumAssets) return;
      final canSelect =
          await selectPredicate?.call(context, currentAsset, isSelected) ??
          true;
      if (!canSelect) return;
      provider.selectAsset(currentAsset);
    }
  }

  @override
  Widget assetGridItemSemanticsBuilder(
    BuildContext context,
    int index,
    AssetEntity asset,
    Widget child,
    List<SpecialItemFinalized> specialItemsFinalized,
  ) {
    return child;
  }

  @override
  Widget imageAndVideoItemBuilder(
    BuildContext context,
    int index,
    AssetEntity asset,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => viewAsset(context, index, asset),
      onLongPress: () => _previewAsset.value = asset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            asset,
            isOriginal: false,
            fit: BoxFit.cover,
            thumbnailSize: const ThumbnailSize.square(300),
          ),
          selectedBackdrop(context, index, asset),
          selectIndicator(context, index, asset),
          itemBannedIndicator(context, asset),
          if (asset.type == AssetType.video) videoIndicator(context, asset),
        ],
      ),
    );
  }

  @override
  Widget assetGridItemBuilder({
    required BuildContext context,
    required int index,
    required List<AssetEntity> currentAssets,
    required List<SpecialItemFinalized> specialItemsFinalized,
  }) {
    final int prependCount =
        specialItemsFinalized
            .where((e) => e.position == SpecialItemPosition.prepend)
            .length;
    final int effectiveIndex = index - prependCount;

    if (effectiveIndex < 0 || effectiveIndex >= currentAssets.length) {
      return super.assetGridItemBuilder(
        context: context,
        index: index,
        currentAssets: currentAssets,
        specialItemsFinalized: specialItemsFinalized,
      );
    }

    final asset = currentAssets[effectiveIndex];
    return assetGridItemSemanticsBuilder(
      context,
      effectiveIndex,
      asset,
      imageAndVideoItemBuilder(context, effectiveIndex, asset),
      specialItemsFinalized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AssetEntity?>(
      valueListenable: _previewAsset,
      builder: (context, previewAsset, child) {
        return Stack(
          children: [
            child!,
            if (previewAsset != null)
              _PreviewOverlay(
                asset: previewAsset,
                onDismiss: () => _previewAsset.value = null,
              ),
          ],
        );
      },
      child: super.build(context),
    );
  }
}

class _PreviewOverlay extends StatefulWidget {
  const _PreviewOverlay({required this.asset, required this.onDismiss});

  final AssetEntity asset;
  final VoidCallback onDismiss;

  @override
  State<_PreviewOverlay> createState() => _PreviewOverlayState();
}

class _PreviewOverlayState extends State<_PreviewOverlay> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await widget.asset.originBytes;
    if (mounted) {
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _bytes == null) {
      return const ColoredBox(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => widget.onDismiss(),
      child: FullscreenImageViewer<Uint8List>(
        images: [_bytes!],
        getBytes: (b) => b,
        getFilePath: (_) => widget.asset.id,
        initialIndex: 0,
        onDismiss: widget.onDismiss,
      ),
    );
  }
}
