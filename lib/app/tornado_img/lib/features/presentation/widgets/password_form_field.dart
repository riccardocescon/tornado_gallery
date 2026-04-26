import 'package:flutter/material.dart';
import 'package:tornado_img_app/extentions.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key, this.onChanged, this.initialValue});

  final void Function(String)? onChanged;
  final String? initialValue;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late final TextEditingController _passwordController;
  bool _obscureText = true;

  @override
  void initState() {
    _passwordController = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: 'Enter your password',
        fillColor: context.appColors.softBackground.withValues(alpha: 0.3),
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
    );
  }
}
