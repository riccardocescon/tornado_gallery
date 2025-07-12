part of 'encrypted_gallery_page.dart';

class _GalleryFAB extends StatelessWidget {
  const _GalleryFAB({required this.encryptedGalleryViewModel});

  final EncryptedGalleryViewModel encryptedGalleryViewModel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return CreateFolderDialog(
              onCreate: (name) {
                encryptedGalleryViewModel
                    .createFolder(name)
                    .then((_) {
                      if (!context.mounted) return;

                      context.showSuccessSnackbar(
                        'Folder created successfully',
                      );
                    })
                    .catchError((error) {
                      if (!context.mounted) return;

                      context.showErrorSnackbar(
                        'Failed to create folder: $error',
                      );
                    });
              },
            );
          },
        );
      },
      child: const Icon(Icons.folder_rounded),
    );
  }
}
