part of '../encrypted_gallery_page.dart';

class _EncryptedGallery extends StatelessWidget {
  final Function(EncryptedImage) onImageSelected;

  const _EncryptedGallery({required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncrpytedGalleryPageBloc, EncrpytedGalleryPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(loaded: (_) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          loaded: (value) => _buildGrid(context, value.images),
          orElse: () => const SizedBox(),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<EncryptedEntity> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(EncryptedGalleryPageConstants.gridPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: EncryptedGalleryPageConstants.gridCrossAxisCount,
        mainAxisSpacing: EncryptedGalleryPageConstants.gridSpacing,
        crossAxisSpacing: EncryptedGalleryPageConstants.gridSpacing,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        if (index >= images.length) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth:
                  EncryptedGalleryPageConstants.progressIndicatorStroke,
            ),
          );
        }

        final entity = images[index];
        if (entity.isImage) {
          return _EncryptedImageTile(
            image: entity.asImage,
            onTap: () => onImageSelected(entity.asImage),
          );
        }
        return _EncryptedFolderTile(folder: entity.asFolder);
      },
    );
  }
}
