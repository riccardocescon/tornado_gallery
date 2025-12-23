import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  /// Returns the current [MediaQuery] of the context.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the current [ThemeData] of the context.
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme] of the context.
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme] of the context.
  ColorScheme get colorScheme => theme.colorScheme;

  void showSuccessSnackbar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }

  void showErrorSnackbar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onErrorContainer,
          ),
        ),
        backgroundColor: colorScheme.errorContainer,
      ),
    );
  }
}
