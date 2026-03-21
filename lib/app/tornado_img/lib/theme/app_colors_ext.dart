import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color softBackground;
  final Color softButton;

  AppColorsExtension({required this.softBackground, required this.softButton});

  @override
  AppColorsExtension copyWith({Color? softBackground, Color? softButton}) {
    return AppColorsExtension(
      softBackground: softBackground ?? this.softBackground,
      softButton: softButton ?? this.softButton,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      softBackground: Color.lerp(softBackground, other.softBackground, t)!,
      softButton: Color.lerp(softButton, other.softButton, t)!,
    );
  }
}
