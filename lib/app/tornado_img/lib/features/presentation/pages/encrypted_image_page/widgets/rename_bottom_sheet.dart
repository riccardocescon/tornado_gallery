part of '../encrypted_image_page.dart';

class _RenameBottomSheet extends StatefulWidget {
  const _RenameBottomSheet({required this.currentName});

  final String currentName;

  @override
  State<_RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<_RenameBottomSheet> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  static final _fileNameRegex = RegExp(r'^[a-zA-Z0-9]+$');
  final images = getIt<AppBloc>().encryptedImages;

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (!_fileNameRegex.hasMatch(value)) {
      return 'Name can only contain letters and numbers';
    }

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
                Text("Rename image", style: context.textTheme.titleMedium),
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
                            context.read<EncryptedImagePageBloc>().add(
                              EncryptedImagePageEvent.rename(
                                newName: _controller.text,
                              ),
                            );
                            context.pop();
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
