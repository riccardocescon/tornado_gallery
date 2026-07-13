part of '../encryption_page.dart';

class _ImagesPreviewCard extends StatelessWidget {
  const _ImagesPreviewCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (state) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          ui: (value) {
            return AppCard(
              child: Column(
                spacing: 12,
                children: [
                  if (value.images.length == 1)
                    _SingleImageLayout(
                      image: value.images.first,
                      initSize: value.size,
                      initDateTime: value.dateTime,
                      initFileName: value.fileName,
                    )
                  else
                    _MultiImagesLayout(
                      images: value.images,
                      initFileName: value.fileName,
                      initSize: value.size,
                      initDateTime: value.dateTime,
                    ),
                  _imagesCompletedCard(),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _imagesCompletedCard() {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      builder: (context, state) {
        return state.maybeMap(
          encrypted: (_) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.appColors.successContainer,
                borderRadius: AppStyle.cardBorderRadius,
              ),
              child: Text(
                'Encryption completed successfully!',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.appColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
