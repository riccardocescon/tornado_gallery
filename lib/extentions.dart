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
}
