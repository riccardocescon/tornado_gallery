part of '../encryption_page.dart';

class _PasswordCard extends StatefulWidget {
  const _PasswordCard({required this.imagesSize});

  final int imagesSize;

  @override
  State<_PasswordCard> createState() => __PasswordCard();
}

class __PasswordCard extends State<_PasswordCard> {

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        boxShadow:
            context.isDarkMode
                ? null
                : [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_password(), if (widget.imagesSize == 1) _name()],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("File name", style: context.textTheme.titleMedium),
        Text(
          "Optionally set a custom name for the encrypted archive (without extension)",
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: _controller,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            onChanged:
                (value) => context.read<EncryptionPageBloc>().add(
                  EncryptionPageEvent.setFileName(name: value),
                ),

            decoration: InputDecoration(
              hintText: 'Enter file name (optional)',
              fillColor: context.appColors.softBackground.withValues(
                alpha: 0.3,
              ),
              prefixIcon: Icon(Icons.drive_file_rename_outline, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
