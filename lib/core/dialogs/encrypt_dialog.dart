import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img/app_style.dart';
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
          SizedBox.square(
            dimension: 100,
            child: ClipRRect(
              borderRadius: AppStyle.borderRadius,
              child: Image.file(widget.image.file, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pick a password to encrypt your image',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(hintText: 'Password'),
            minLines: 1,
            maxLines: 3,
            onChanged: (value) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Cancel', style: context.textTheme.bodySmall),
        ),
        TextButton(
          onPressed:
              _passwordController.text.isEmpty
                  ? null
                  : () => widget.onEncrypt(_passwordController.text),
          child: Text(
            'Encrypt',
            style: context.textTheme.bodySmall?.copyWith(
              color:
                  _passwordController.text.isEmpty
                      ? context.colorScheme.onSurface.withValues(alpha: 0.4)
                      : context.colorScheme.primary,
              fontWeight:
                  _passwordController.text.isEmpty ? null : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
