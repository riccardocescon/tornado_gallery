import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img/app_style.dart';
import 'package:tornado_img/core/animations/glitch_loader.dart';
import 'package:tornado_img/extentions.dart';
import 'package:tornado_img/features/models/gallery_image.dart';

class EncryptDialog extends StatefulWidget {
  const EncryptDialog({
    super.key,
    required this.image,
    required this.onEncrypt,
  });

  final GalleryImage image;
  final void Function(String password) onEncrypt;

  @override
  State<EncryptDialog> createState() => _EncryptDialogState();
}

class _EncryptDialogState extends State<EncryptDialog> {
  final _passwordController = TextEditingController();

  bool isLoading = false;

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
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              minLines: 1,
              maxLines: 3,
              onChanged: (value) => setState(() {}),
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
                            widget.onEncrypt(_passwordController.text);
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
        borderRadius: AppStyle.borderRadius,
        child: Image.file(widget.image.file, fit: BoxFit.cover),
      ),
    );

    if (!isLoading) return image;

    return ClipRRect(
      borderRadius: AppStyle.borderRadius,
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
}
