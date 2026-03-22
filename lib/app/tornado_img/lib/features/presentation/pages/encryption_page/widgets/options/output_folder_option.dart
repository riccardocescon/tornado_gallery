part of '../../encryption_page.dart';

class _OutputFolderOption extends StatelessWidget {
  const _OutputFolderOption();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) => current.maybeMap(
            settingsUi: (state) => true,
            orElse: () => false,
          ),
      builder: (context, state) {
        final outputFolder = state.maybeMap(
          settingsUi: (state) => state.outputFolder,
          orElse: () => "",
        );
        final isLoading = outputFolder.isEmpty;

        return _OptionItem(
          icon: Icons.folder_outlined,
          title: "Output Folder",
          overrideSubtitle:
              isLoading ? LoadingContainer(width: 300, height: 16) : null,
          subtitle: outputFolder,
          trailing: Container(),
          // trailing: TextButton(
          //   onPressed: () {
          //     showModalBottomSheet(
          //       context: context,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.vertical(
          //           top: AppStyle.cardBorderRadius.topLeft,
          //         ),
          //       ),
          //       builder: (context) => const _OutputFolderBottomSheet(),
          //     );
          //   },
          //   child: Text(
          //     "Chance",
          //     style: context.textTheme.labelSmall?.copyWith(
          //       fontWeight: FontWeight.w500,
          //       color: context.colorScheme.tertiary,
          //     ),
          //   ),
          // ),
        );
      },
    );
  }
}

class _OutputFolderBottomSheet extends StatelessWidget {
  const _OutputFolderBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Select Output Folder", style: context.textTheme.titleMedium),
      ],
    );
  }
}
