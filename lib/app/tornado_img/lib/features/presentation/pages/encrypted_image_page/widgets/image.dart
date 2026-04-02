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
        final isLoading = state.maybeMap(
          loading: (_) => true,
          ui: (value) {
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
            child: Transform.scale(
              scale: 10,
              child: Skeletonizer(
                enabled: isLoading,
                child: Image.memory(bytes!, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}
