part of '../encrypted_image_page.dart';

class _Image extends StatefulWidget {
  const _Image({required this.image});

  final GalleryImage image;

  @override
  State<_Image> createState() => __ImageState();
}

class __ImageState extends State<_Image> {
  Uint8List? imageBytes;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  @override
  void didUpdateWidget(covariant _Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.file.path != widget.image.file.path) {
      _loadImageBytes();
    }
  }

  Future<void> _loadImageBytes() async {
    if (imageBytes != null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await widget.image.file.readAsBytes();
      if (!mounted) return;
      setState(() {
        imageBytes = bytes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Errore caricamento immagine'));
    }
    if (imageBytes != null) {
      return Center(
        child: ClipRRect(
          borderRadius: AppStyle.cardBorderRadius,
          child: Transform.scale(
            scale: 10,
            child: Image.memory(imageBytes!, fit: BoxFit.contain),
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
