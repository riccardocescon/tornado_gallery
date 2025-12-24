import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';
import 'package:tornado_img_app/features/presentation/bloc/gallery_page_bloc/gallery_page_bloc.dart';
import 'package:tornado_img_app/features/presentation/pages/gallery_page/gallery_opened_image.dart';
import 'package:tornado_img_app/features/presentation/widgets/cached_image_widget.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  GalleryImage? _selectedImage;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  final ValueNotifier<(int, int)> _visibleRange = ValueNotifier((0, 20));

  @override
  void initState() {
    context.read<GalleryPageBloc>().add(const GalleryPageEvent.setup());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _visibleRange.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    // Aggiorna range visibile per memory management
    _updateVisibleRange();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _isLoadingMore = true;
      context.read<GalleryPageBloc>().add(
        const GalleryPageEvent.loadNextPage(),
      );
    }
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;

    const itemHeight = 4 + 8 / 3; // spacing + height / crossAxisCount
    final scrollTop = _scrollController.position.pixels;
    final viewHeight = _scrollController.position.viewportDimension;

    final startIndex =
        (scrollTop / itemHeight * 3).floor().clamp(0, double.infinity).toInt();
    final endIndex =
        ((scrollTop + viewHeight) / itemHeight * 3)
            .ceil()
            .clamp(0, double.infinity)
            .toInt();

    _visibleRange.value = (startIndex, endIndex + 10); // +10 per buffer
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _selectedImage = null;
          });
        }
      },
      child: BlocListener<GalleryPageBloc, GalleryPageState>(
        listenWhen: (previous, current) {
          return current.maybeMap(
            loaded: (value) {
              return previous.maybeMap(
                loaded: (prev) => prev.images.length != value.images.length,
                orElse: () => true,
              );
            },
            encrypted: (value) => true,
            failure: (value) => true,
            orElse: () => false,
          );
        },
        listener: (context, state) {
          state.maybeMap(
            loaded: (value) {
              _isLoadingMore = false;
            },
            encrypted: (value) {
              context.pop();
              context.showSuccessSnackbar('Image encrypted successfully!');
            },
            failure: (value) {
              context.showErrorSnackbar(value.message);
            },
            orElse: () {},
          );
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Local Gallery')),
          floatingActionButton:
              _selectedImage != null
                  ? null
                  : FloatingActionButton(
                    onPressed: () {
                      context.read<GalleryPageBloc>().add(
                        GalleryPageEvent.pickFiles(),
                      );
                    },
                    child: const Icon(Icons.download_rounded),
                  ),
          body: Stack(
            children: [
              _gallery(),
              if (_selectedImage != null)
                GalleryOpenedImage(
                  image: _selectedImage!,
                  onEncrypt: (password, path) {
                    context.read<GalleryPageBloc>().add(
                      GalleryPageEvent.encryptImage(
                        image: _selectedImage!,
                        password: password,
                        path: path,
                      ),
                    );
                  },
                  onDelete: () {
                    context.read<GalleryPageBloc>().add(
                      GalleryPageEvent.deleteImage(image: _selectedImage!),
                    );
                    context.pop();
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gallery() {
    return BlocBuilder<GalleryPageBloc, GalleryPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(loaded: (value) => true, orElse: () => false),
      builder: (context, state) {
        return state.maybeMap(
          loaded: (value) {
            return GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(8),
              cacheExtent: 1000, // Limita il cache per ridurre memory usage
              addRepaintBoundaries: false, // Riduce overhead di repaint
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: value.images.length,
              itemBuilder: (context, index) {
                final image = value.images[index];
                return CachedImageWidget(
                  key: ValueKey(image.file.path),
                  image: image,
                  index: index,
                  currentVisibleRange: _visibleRange,
                  onTap: () {
                    setState(() {
                      _selectedImage = image;
                    });
                  },
                );
              },
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      
      },
    );
  }

}
