import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tornado_img_app/theme/app_colors_ext.dart';

extension BuildContextX on BuildContext {
  /// Returns the current [MediaQuery] of the context.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the current [ThemeData] of the context.
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme] of the context.
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme] of the context.
  ColorScheme get colorScheme => theme.colorScheme;

  AppColorsExtension get appColors => theme.extension<AppColorsExtension>()!;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

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

  void showSnackbar(
    String text, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(text), duration: duration));
  }
}

extension ListX<T> on List<T> {
  /// Returns the first element that satisfies the given [predicate], or `null` if no such element is found.
  T? firstWhereOrNull(bool Function(T) predicate) {
    for (final element in this) {
      if (predicate(element)) {
        return element;
      }
    }
    return null;
  }
}

extension EitherX<L, R> on Either<L, R> {
  L get left => fold((l) => l, (r) => throw StateError('No left value'));

  R get right => fold((l) => throw StateError('No right value'), (r) => r);
}
