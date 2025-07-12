import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tornado_img/extentions.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key, required this.onCreate});

  final void Function(String name) onCreate;

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AlertDialog(
        title: Text(
          'Create Folder',
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.colorScheme.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter folder name:',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Folder name cannot be empty';
                }
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Folder name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              context.pop();
              widget.onCreate(_nameController.text.trim());
            },
            child: Text(
              'Create',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
