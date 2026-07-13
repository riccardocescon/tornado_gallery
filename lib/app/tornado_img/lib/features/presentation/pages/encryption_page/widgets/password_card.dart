part of '../encryption_page.dart';

class _PasswordCard extends StatefulWidget {
  const _PasswordCard({required this.imagesSize});

  final int imagesSize;

  @override
  State<_PasswordCard> createState() => __PasswordCard();
}

class __PasswordCard extends State<_PasswordCard> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_password(), _name()],
      ),
    );
  }

  Widget _password() {
    final pageBloc = context.read<EncryptionPageBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password", style: context.textTheme.titleMedium),
        Text(
          "This password will be used to encrypt your images",
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: PasswordFormField(
            initialValue: pageBloc.password,
            onChanged:
                (value) => pageBloc.add(
                  EncryptionPageEvent.setPassword(password: value),
                ),
          ),
        ),
      ],
    );
  }

  Widget _name() {
    return BlocBuilder<EncryptionPageBloc, EncryptionPageState>(
      buildWhen:
          (previous, current) =>
              current.maybeMap(ui: (value) => true, orElse: () => false),
      builder: (context, state) {
        final fileName = state.maybeMap(
          ui: (value) => value.fileName,
          orElse: () => '',
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("File name", style: context.textTheme.titleMedium),
            Text(
              "Optionally set a custom name for the encrypted image (without extension)",
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: _FileNameField(
                defaultFileName: fileName,
                onChanged:
                    (value) => context.read<EncryptionPageBloc>().add(
                      EncryptionPageEvent.setFileName(name: value),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FileNameField extends StatefulWidget {
  const _FileNameField({
    required this.defaultFileName,
    required this.onChanged,
  });

  final String defaultFileName;
  final ValueChanged<String> onChanged;

  @override
  State<_FileNameField> createState() => _FileNameFieldState();
}

class _FileNameFieldState extends State<_FileNameField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultFileName);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(_FileNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultFileName != widget.defaultFileName) {
      setState(() {
        _isDefault = true;
        _controller.text = widget.defaultFileName;
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _isDefault = true;
        _controller.text = widget.defaultFileName;
      });
      widget.onChanged(widget.defaultFileName);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      onTap: () {
        if (_isDefault) {
          setState(() {
            _isDefault = false;
            _controller.clear();
          });
        }
      },
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        if (_isDefault) {
          setState(() => _isDefault = false);
        }
        widget.onChanged(value.isEmpty ? widget.defaultFileName : value);
      },
      style:
          _isDefault
              ? TextStyle(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              )
              : null,
      decoration: InputDecoration(
        fillColor: context.appColors.softBackground.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        prefixIcon: const Icon(Icons.drive_file_rename_outline, size: 20),
      ),
    );
  }
}
