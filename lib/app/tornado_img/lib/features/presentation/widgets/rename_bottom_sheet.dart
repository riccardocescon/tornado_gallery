import 'package:flutter/material.dart';
import 'package:tornado_img_app/core/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:tornado_img_app/core/utils/file_name_validator.dart';
import 'package:tornado_img_app/extentions.dart';
import 'package:tornado_img_app/injection_container.dart';

/// Bottom sheet that asks for a new file name and hands it to [onRename].
///
/// Shared by the encrypted image and video pages, so it stays caller-agnostic:
/// the name validation reads [AppBloc] directly from `get_it`, and applying the
/// rename is the caller's job.
class RenameBottomSheet extends StatefulWidget {
  const RenameBottomSheet({
    super.key,
    required this.currentName,
    required this.onRename,
    this.title = 'Rename image',
  });

  /// Current name **without** its extension.
  final String currentName;
  final ValueChanged<String> onRename;
  final String title;

  @override
  State<RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<RenameBottomSheet> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  String? _validate(String? value) {
    final baseError = validateFileName(value);
    if (baseError != null) return baseError;

    final images = getIt<AppBloc>().encryptedImages;
    final alreadyExists = images.any((image) {
      final nameWithoutExtension = image.name.split('.').first;
      return nameWithoutExtension == value;
    });
    if (alreadyExists) {
      return 'A file with this name already exists';
    }
    return null;
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.currentName);
    _controller.addListener(_onChanged);
    super.initState();
  }

  void _onChanged() {
    final error = _validate(_controller.text);
    if (error != _errorText) {
      setState(() => _errorText = error);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: context.textTheme.titleMedium),
                TextFormField(
                  controller: _controller,
                  validator: _validate,
                  decoration: InputDecoration(
                    labelText: "New name",
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                    errorStyle: TextStyle(color: context.colorScheme.error),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _errorText == null
                          ? () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            widget.onRename(_controller.text);
                            // Plain Navigator: the sheet is a modal route, not
                            // a GoRouter one.
                            Navigator.of(context).pop();
                          }
                          : null,
                  child: const Text("Rename"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
