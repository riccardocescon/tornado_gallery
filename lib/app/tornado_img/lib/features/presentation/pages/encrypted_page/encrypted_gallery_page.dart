import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/dialogs/create_folder_dialog.dart';
import 'package:tornado_img_app/core/dialogs/decrypt_dialog.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_entity.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_folder.dart';
import 'package:tornado_img_app/features/domain/entities/encrypted/encrypted_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/encrypted_gallery_page_bloc/encrypted_gallery_page_bloc.dart';

part 'utils/constants.dart';
part 'widgets/gallery_fab.dart';
part 'widgets/encrypted_gallery.dart';
part 'widgets/encrypted_folder_tile.dart';
part 'widgets/encrypted_image_tile.dart';
part 'widgets/encrypted_opened_image.dart';

class EncryptedGalleryPage extends StatefulWidget {
  const EncryptedGalleryPage({super.key});

  @override
  State<EncryptedGalleryPage> createState() => _EncryptedGalleryPageState();
}

class _EncryptedGalleryPageState extends State<EncryptedGalleryPage> {
  EncryptedImage? _selectedImage;

  @override
  void initState() {
    super.initState();
    _setupGallery();
  }

  void _setupGallery() {
    context.read<EncrpytedGalleryPageBloc>().add(
      const EncrpytedGalleryPageEvent.setup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _updateSelectedImage(null);
      },
      child: _buildScaffoldWithListener(),
    );
  }

  Widget _buildScaffoldWithListener() {
    return BlocListener<EncrpytedGalleryPageBloc, EncrpytedGalleryPageState>(
      listenWhen: _shouldListen,
      listener: _handleBlocState,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _GalleryFAB(),
      body: _buildBody(),
    );
  }

  // UI event handlers
  void _updateSelectedImage(EncryptedImage? image) {
    setState(() => _selectedImage = image);
  }

  void _onImageDecrypt(String password) {
    if (_selectedImage == null) return;

    context.read<EncrpytedGalleryPageBloc>().add(
      EncrpytedGalleryPageEvent.decryptImage(
        image: _selectedImage!,
        password: password,
        path: null,
      ),
    );
  }

  void _onImageDelete() {
    if (_selectedImage == null) return;

    context.read<EncrpytedGalleryPageBloc>().add(
      EncrpytedGalleryPageEvent.deleteImage(image: _selectedImage!),
    );
    context.pop();
    setState(() => _selectedImage = null);
  }

  // AppBar methods
  AppBar _buildAppBar() {
    final root = context.read<EncrpytedGalleryPageBloc>().root;

    return AppBar(
      title: Text(_buildTitle(root)),
      actions: _buildAppBarActions(root),
    );
  }

  String _buildTitle(String? root) {
    if (root == null) return EncryptedGalleryPageConstants.defaultTitle;

    return root
        .split('/')
        .reversed
        .take(EncryptedGalleryPageConstants.pathSegmentsToShow)
        .toList()
        .reversed
        .join('/');
  }

  List<Widget> _buildAppBarActions(String? root) {
    return [
      _buildDecryptFolderButton(),
      if (root != null) _buildDeleteFolderButton(root),
    ];
  }

  Widget _buildDecryptFolderButton() {
    return IconButton(
      onPressed: _showDecryptDialog,
      icon: const Icon(
        Icons.lock_open_rounded,
        size: EncryptedGalleryPageConstants.appBarIconSize,
      ),
    );
  }

  Widget _buildDeleteFolderButton(String root) {
    return IconButton(
      onPressed: () => _showDeleteFolderDialog(root),
      icon: Icon(
        Icons.delete_rounded,
        color: context.colorScheme.error,
        size: EncryptedGalleryPageConstants.appBarIconSize,
      ),
    );
  }

  // Body methods
  Widget _buildBody() {
    return Stack(
      children: [
        _EncryptedGallery(onImageSelected: _updateSelectedImage),
        if (_selectedImage != null) _buildOpenedImage(),
      ],
    );
  }

  Widget _buildOpenedImage() {
    return EncryptedOpenedImage(
      image: _selectedImage!,
      onDecrypt: _onImageDecrypt,
      onDelete: _onImageDelete,
    );
  }

  // Dialog methods
  void _showDecryptDialog() {
    showGeneralDialog(
      context: context,
      pageBuilder: (dialogContext, _, __) {
        return DecryptDialog(
          onDecrypt: (password) {
            context.read<EncrpytedGalleryPageBloc>().add(
              EncrpytedGalleryPageEvent.decryptFolder(password: password),
            );
            dialogContext.pop();
          },
        );
      },
    );
  }

  void _showDeleteFolderDialog(String root) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text(
            EncryptedGalleryPageConstants.deleteDialogTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.error,
            ),
          ),
          content: _buildDeleteDialogContent(context, root),
          actions: _buildDeleteDialogActions(),
        );
      },
    );
  }

  Widget _buildDeleteDialogContent(BuildContext context, String root) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          EncryptedGalleryPageConstants.deleteDialogContent,
          style: context.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          '${EncryptedGalleryPageConstants.folderPrefix}$root',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDeleteDialogActions() {
    return [
      TextButton(
        onPressed: () => context.pop(),
        child: Text(
          EncryptedGalleryPageConstants.cancelButton,
          style: context.textTheme.bodySmall,
        ),
      ),
      TextButton(
        onPressed: _onDeleteFolder,
        child: Text(
          EncryptedGalleryPageConstants.deleteButton,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.error,
          ),
        ),
      ),
    ];
  }

  void _onDeleteFolder() {
    context.read<EncrpytedGalleryPageBloc>().add(
      const EncrpytedGalleryPageEvent.deleteFolder(),
    );
    context.pop(); // Close dialog
  }

  // BlocListener methods
  bool _shouldListen(
    EncrpytedGalleryPageState previous,
    EncrpytedGalleryPageState current,
  ) {
    return current.maybeMap(
      decrypted:
          (_) => previous.maybeMap(loading: (_) => true, orElse: () => false),
      failure: (_) => true,
      orElse: () => false,
    );
  }

  void _handleBlocState(BuildContext context, EncrpytedGalleryPageState state) {
    state.maybeMap(
      decrypted: _onDecryptedState,
      failure: _onFailureState,
      orElse: () {},
    );
  }

  void _onDecryptedState(dynamic value) {
    context.pop(); // Closes loading dialog
    setState(() {
      _selectedImage?.decryptedBytes = value.data;
    });
  }

  void _onFailureState(dynamic value) {
    context.showErrorSnackbar(value.message);
  }
}
