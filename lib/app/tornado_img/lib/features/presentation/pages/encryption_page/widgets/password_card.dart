part of '../encryption_page.dart';

class _PasswordCard extends StatefulWidget {
  const _PasswordCard();

  @override
  State<_PasswordCard> createState() => __PasswordCard();
}

class __PasswordCard extends State<_PasswordCard> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: AppStyle.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
            child: TextFormField(
              controller: _passwordController,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              onChanged: (value) {
                context.read<EncryptionPageBloc>().add(
                  EncryptionPageEvent.setPassword(password: value),
                );
              },
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                fillColor: context.appColors.softBackground.withValues(
                  alpha: 0.3,
                ),
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
