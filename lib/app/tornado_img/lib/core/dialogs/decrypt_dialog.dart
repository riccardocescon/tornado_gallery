import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img_app/core/animations/animated_text.dart';
import 'package:tornado_img_app/extentions.dart';

class DecryptDialog extends StatefulWidget {
  const DecryptDialog({super.key, required this.onDecrypt});

  final void Function(String password) onDecrypt;

  @override
  State<DecryptDialog> createState() => _DecryptDialogState();
}

class _DecryptDialogState extends State<DecryptDialog> {
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
        'Decrypt',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? AnimatedText(
                texts: [
                  'Decrypting your image.',
                  'Decrypting your image..',
                  'Decrypting your image...',
                ],
              )
              :
          Text(
                'Write the password to decrypt your image',
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
                            widget.onDecrypt(_passwordController.text);
                          },
                  child: Text(
                    'Decrypt',
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
}
