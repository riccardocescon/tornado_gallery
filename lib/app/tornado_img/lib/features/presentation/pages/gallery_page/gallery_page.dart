import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
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
  bool _hasRestoredPosition = false; // Track se abbiamo già ripristinato
  Timer? _savePositionTimer; // Debounce timer per salvataggio posizione

  @override
  void initState() {
    context.read<GalleryPageBloc>().add(const GalleryPageEvent.setup());
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Trigger ripristino posizione se le immagini sono già caricate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<GalleryPageBloc>();
      bloc.state.maybeMap(
        loaded: (value) {
          print(
            '📱 InitState: Trovate ${value.images.length} immagini già caricate',
          );
          if (!_hasRestoredPosition) {
            _hasRestoredPosition = true;
            Future.delayed(const Duration(milliseconds: 200), () {
              _restoreScrollPosition();
            });
          }
        },
        orElse: () => print('📱 InitState: Nessuna immagine caricata ancora'),
      );
    });
    
    super.initState();
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    _scrollController.dispose();
    _visibleRange.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    // Debounce: salva posizione solo quando smette di scrollare per 500ms
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(const Duration(milliseconds: 500), () {
      _saveScrollPosition();
    });

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

    _visibleRange.value = (
      startIndex,
      endIndex + 6,
    ); // Buffer ridotto per batteria
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      final galleryBloc = context.read<GalleryPageBloc>().galleryBloc;
      final currentPosition = _scrollController.position.pixels;
      galleryBloc.savedScrollPosition = currentPosition;
      print('💾 Salvata posizione scroll: $currentPosition');
    }
  }

  void _restoreScrollPosition() {
    if (!mounted) return;

    final galleryBloc = context.read<GalleryPageBloc>().galleryBloc;
    final savedPosition = galleryBloc.savedScrollPosition;

    if (savedPosition != null && _scrollController.hasClients) {
      // Controlla che la posizione sia valida per il contenuto attuale
      final maxScroll = _scrollController.position.maxScrollExtent;

      // Se maxScroll è 0, aspetta un po' di più che il contenuto si carichi
      if (maxScroll == 0.0) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _restoreScrollPosition();
        });
        return;
      }

      final targetPosition = savedPosition.clamp(0.0, maxScroll);

      print(
        '🔄 Ripristino scroll: saved=$savedPosition, max=$maxScroll, target=$targetPosition',
      );

      // Jump diretto senza animazione - istantaneo e più efficiente
      _scrollController.jumpTo(targetPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Salva posizione quando si chiude l'immagine aperta
          _saveScrollPosition();
          setState(() {
            _selectedImage = null;
          });
        }
      },
      child: BlocListener<GalleryPageBloc, GalleryPageState>(
        listenWhen: (previous, current) {
          // Sempre ascolta i loaded state per ripristinare posizione
          return current.maybeMap(
            loaded: (value) => true, // Sempre true per loaded
            encrypted: (value) => true,
            failure: (value) => true,
            orElse: () => false,
          );
        },
        listener: (context, state) {
          state.maybeMap(
            loaded: (value) {
              print(
                '🔥 BlocListener: loaded state con ${value.images.length} immagini',
              );
              _isLoadingMore = false;
              // Ripristina posizione scroll solo una volta quando le immagini sono caricate
              if (!_hasRestoredPosition) {
                print('✅ Primo caricamento, ripristino posizione...');
                _hasRestoredPosition = true;
                // Ritardo più lungo per assicurarsi che il GridView sia completamente renderizzato
                Future.delayed(const Duration(milliseconds: 200), () {
                  _restoreScrollPosition();
                });
              } else {
                print('⏭️ Posizione già ripristinata, skip');
              }
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
              // Ottimizzazioni conservative per batteria
              cacheExtent: 400, // Bilanciato per batteria vs performance
              addRepaintBoundaries: true, // Isola repaint per widget
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
                    // Salva posizione prima di aprire l'immagine
                    _saveScrollPosition();
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
