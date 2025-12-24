part of 'encrypted_gallery_page.dart';

class _GalleryFAB extends StatelessWidget {
  const _GalleryFAB();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return CreateFolderDialog(
              onCreate: (name) {
                context.read<EncrpytedGalleryPageBloc>().add(
                  EncrpytedGalleryPageEvent.createFolder(folderName: name),
                );
              },
            );
          },
        );
      },
      child: const Icon(Icons.folder_rounded),
    );
  }
}
