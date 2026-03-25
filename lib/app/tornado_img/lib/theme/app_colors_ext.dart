import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color softBackground;
  final Color softButton;
  final Color success;
  final Color successContainer;

  AppColorsExtension({
    required this.softBackground,
    required this.softButton,
    required this.success,
    required this.successContainer,
  });

  @override
  AppColorsExtension copyWith({
    Color? softBackground,
    Color? softButton,
    Color? success,
    Color? successContainer,
  }) {
    return AppColorsExtension(
      softBackground: softBackground ?? this.softBackground,
      softButton: softButton ?? this.softButton,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      softBackground: Color.lerp(softBackground, other.softBackground, t)!,
      softButton: Color.lerp(softButton, other.softButton, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
    );
  }
}
