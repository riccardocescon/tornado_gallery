import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/app_style.dart';
import 'package:tornado_img_app/core/animations/glitch_loader.dart';
import 'package:tornado_img_app/core/utils/paths.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/features/domain/entities/gallery_image.dart';

class EncryptDialog extends StatefulWidget {
  const EncryptDialog({
    super.key,
    required this.image,
    required this.onEncrypt,
  });

  final GalleryImage image;
  final void Function(String password, String? path) onEncrypt;

  @override
  State<EncryptDialog> createState() => _EncryptDialogState();
}

class _EncryptDialogState extends State<EncryptDialog> {
  final _passwordController = TextEditingController();

  bool isLoading = false;
  String? selectedFolder;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Encrypt',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _preview(),
          const SizedBox(height: 16),
          Text(
            isLoading
                ? 'Encrypting your image...'
                : 'Pick a password to encrypt your image',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Text(
              'This process may take a few seconds, please wait.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            )
          else
            Column(
              children: [
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'Password'),
                  minLines: 1,
                  maxLines: 3,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _folderSection(),
              ],
            ),
        ],
      ),
      actions:
          isLoading
              ? []
              : [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Cancel', style: context.textTheme.bodySmall),
                ),
                TextButton(
                  onPressed:
                      _passwordController.text.isEmpty
                          ? null
                          : () {
                            setState(() {
                              isLoading = true;
                            });
                            widget.onEncrypt(
                              _passwordController.text,
                              selectedFolder,
                            );
                          },
                  child: Text(
                    'Encrypt',
                    style: context.textTheme.bodySmall?.copyWith(
                      color:
                          _passwordController.text.isEmpty
                              ? context.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              )
                              : context.colorScheme.primary,
                      fontWeight:
                          _passwordController.text.isEmpty
                              ? null
                              : FontWeight.w600,
                    ),
                  ),
                ),
              ],
    );
  }

  Widget _preview() {
    final image = SizedBox.square(
      dimension: 100,
      child: ClipRRect(
        borderRadius: AppStyle.cardBorderRadius,
        child: Image.file(widget.image.file, fit: BoxFit.cover),
      ),
    );

    if (!isLoading) return image;

    return ClipRRect(
      borderRadius: AppStyle.cardBorderRadius,
      child: SizedBox.square(
        dimension: 100,
        child: GlitchLoader(
          maxGlitchPixelCount: 20000,
          glitchInterval: const Duration(milliseconds: 1),
          pixelSize: 3,
          child: image,
        ),
      ),
    );
  }

  Widget _folderSection() {
    return FutureBuilder(
      future: getFolderPaths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text(
            'Error loading folders: ${snapshot.error}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
          );
        }

        final List<String> folderData = snapshot.data ?? [];
        if (folderData.isEmpty) {
          return Text(
            'No folders available for encryption.',
            style: context.textTheme.bodySmall,
          );
        }

        final List<String?> folderPaths = <String?>[null, ...folderData];
        return DropdownButtonFormField<String?>(
          decoration: InputDecoration(
            hintText: 'Select Folder',
            border: OutlineInputBorder(
              borderRadius: AppStyle.cardBorderRadius,
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            icon: const Icon(Icons.folder_open_rounded, size: 20),
            iconColor: context.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          borderRadius: AppStyle.cardBorderRadius,
          isExpanded: true,
          items:
              folderPaths.map((path) {
                return DropdownMenuItem<String?>(
                  value: path,
                  child: Text(
                    path == null ? 'root' : path.split('/').skip(7).join('/'),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            selectedFolder = value;
          },
        );
      },
    );
  }
}
