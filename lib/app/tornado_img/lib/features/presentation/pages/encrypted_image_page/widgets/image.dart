part of '../encrypted_image_page.dart';

class _Image extends StatefulWidget {
  const _Image();

  @override
  State<_Image> createState() => __ImageState();
}

class __ImageState extends State<_Image> {

  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptedImagePageBloc, EncryptedImagePageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            loading: (_) => true,
            ui: (value) => true,
            orElse: () => false,
          ),
      builder: (context, state) {
        bool isDecrypted = false;
        final isLoading = state.maybeMap(
          loading: (_) => true,
          ui: (value) {
            isDecrypted = value.image.decryptInfo != null;
            bytes =
                value.image.decryptInfo?.bytes ??
                value.image.encryptedInfo.bytes;
            return false;
          },
          orElse: () => null,
        );

        if (bytes == null || isLoading == null) {
          return const SizedBox();
        }

        return Center(
          child: ClipRRect(
            borderRadius: AppStyle.cardBorderRadius,
            child: GestureDetector(
              onTap: () {
                final bloc = context.read<EncryptedImagePageBloc>();
                final allImages = context.read<AppBloc>().encryptedImages;
                final index = allImages.indexWhere(
                  (img) =>
                      img.storagePath.file.path ==
                      bloc.image.storagePath.file.path,
                );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder:
                        (_) => FullscreenImageViewer(
                          images: allImages,
                          getBytes:
                              (image) =>
                                  image.decryptInfo?.bytes ??
                                  image.encryptedInfo.bytes,
                          getFilePath: (image) => image.storagePath.path,
                          initialIndex: index == -1 ? 0 : index,
                        ),
                  ),
                );
              },
              child: Transform.scale(
                scale: isDecrypted ? 1 : 10,
                child: Skeletonizer(
                  enabled: isLoading,
                  child: Image.memory(bytes!, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
