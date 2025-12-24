import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/core/dialogs/encrypt_dialog.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/widgets/cached_image_widget.dart';


part 'utils/scroll_manager.dart';
part 'utils/constants.dart';
part 'widgets/gallery_opened_image.dart';
part 'widgets/gallery.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryImage? _selectedImage;
  late GalleryScrollManager _scrollManager;
  bool _hasRestoredPosition = false;

  @override
  void initState() {
    super.initState();
    _initializeScrollManager();
    _setupGallery();
  }

  void _initializeScrollManager() {
    _scrollManager = GalleryScrollManager(
      onLoadMore: _loadNextPage,
      onPositionSaved: _saveScrollPosition,
    );
  }

  void _setupGallery() {
    context.read<GalleryPageBloc>().add(const GalleryPageEvent.setup());
    
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _tryRestoreInitialPosition(),
    );
  }

  void _tryRestoreInitialPosition() {
    final bloc = context.read<GalleryPageBloc>();
    bloc.state.maybeMap(
      loaded: (value) {
        log(
          '📱 InitState: Found ${value.images.length} images already loaded');
        if (!_hasRestoredPosition) {
          _restoreScrollPosition();
        }
      },
      orElse: () => log('📱 InitState: No images loaded yet'),
    );
  }

  @override
  void dispose() {
    _scrollManager.dispose();
    super.dispose();
  }

  // Scroll management methods
  void _loadNextPage() {
    context.read<GalleryPageBloc>().add(const GalleryPageEvent.loadNextPage());
  }

  void _saveScrollPosition(double position) {
    final galleryPageBloc = context.read<GalleryPageBloc>();
    galleryPageBloc.add(
      GalleryPageEvent.saveScrollPosition(position: position),
    );
  }

  void _restoreScrollPosition() {
    if (!mounted || _hasRestoredPosition) return;

    _hasRestoredPosition = true;
    final galleryPageBloc = context.read<GalleryPageBloc>();
    final currentState = galleryPageBloc.state;

    double? savedPosition;
    currentState.mapOrNull(
      loaded: (state) => savedPosition = state.savedScrollPosition,
    );

    Future.delayed(GalleryPageConstants.positionRestoreDelay, () {
      _scrollManager.restorePosition(savedPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _updateSelectedImage(null);
      },
      child: _buildScaffoldWithListener(),
    );
  }

  Widget _buildScaffoldWithListener() {
    return BlocListener<GalleryPageBloc, GalleryPageState>(
      listenWhen: _shouldListen,
      listener: _handleBlocState,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text(GalleryPageConstants.appBarTitle)),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedImage != null) return null;

    return FloatingActionButton(
      onPressed: _onPickFiles,
      child: const Icon(Icons.download_rounded),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _Gallery(
          scrollController: _scrollManager.controller,
          visibleRange: _scrollManager.visibleRange,
          onImageSelected: _updateSelectedImage,
        ),
        if (_selectedImage != null) _buildOpenedImage(),
      ],
    );
  }

  Widget _buildOpenedImage() {
    return _GalleryOpenedImage(
      image: _selectedImage!,
      onEncrypt: _onImageEncrypt,
      onDelete: _onImageDelete,
    );
  }

  //#region BlocListener methods
  bool _shouldListen(GalleryPageState previous, GalleryPageState current) {
    return current.maybeMap(
      loaded: (_) => true,
      encrypted: (_) => true,
      failure: (_) => true,
      orElse: () => false,
    );
  }

  void _handleBlocState(BuildContext context, GalleryPageState state) {
    state.maybeMap(
      loaded: _onLoadedState,
      encrypted: _onEncryptedState,
      failure: _onFailureState,
      orElse: () {},
    );
  }

  void _onLoadedState(dynamic value) {
    log('🔥 BlocListener: loaded state with ${value.images.length} images');
    _scrollManager.setLoadingCompleted();

    if (_hasRestoredPosition) {
      log('⏭️ Position already restored, skip');
      return;
    }

    log('✅ First loading, restoring position...');
    _restoreScrollPosition();
  }

  void _onEncryptedState(dynamic value) {
    context.pop();
    context.showSuccessSnackbar(GalleryPageConstants.encryptSuccessMessage);
  }

  void _onFailureState(dynamic value) {
    context.showErrorSnackbar(value.message);
  }
  //#endregion

  //#region UI event handlers
  void _updateSelectedImage(GalleryImage? image) {
    if (image == null) {
      _saveScrollPosition(_scrollManager.controller.position.pixels);
    }
    setState(() => _selectedImage = image);
  }

  void _onImageEncrypt(String password, String? path) {
    if (_selectedImage == null) return;

    context.read<GalleryPageBloc>().add(
      GalleryPageEvent.encryptImage(
        image: _selectedImage!,
        password: password,
        path: path,
      ),
    );
  }

  void _onImageDelete() {
    if (_selectedImage == null) return;

    context.read<GalleryPageBloc>().add(
      GalleryPageEvent.deleteImage(image: _selectedImage!),
    );
    context.pop();
    setState(() => _selectedImage = null);
  }

  void _onPickFiles() {
    context.read<GalleryPageBloc>().add(GalleryPageEvent.pickFiles());
  }

  //#endregion
}
