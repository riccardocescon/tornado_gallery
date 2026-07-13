import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color softBackground;
  final Color softButton;
  final Color success;
  final Color successContainer;
  final Color scaffoldBackground;

  // Accent tokens (use these for primary actions, highlighted icons,
  // and the gradient "hero" cards so shading stays consistent everywhere).
  final Color accent; // primary action / highlight color
  final Color onAccent; // text & icons placed on top of [accent]
  final Color accentSubtle; // low-opacity accent for tinted icon chips
  final Color heroGradientStart; // top-left of highlighted hero cards
  final Color heroGradientEnd; // bottom-right of highlighted hero cards

  // Pro tokens. A purple brand family, deliberately separate from [accent] so
  // Pro surfaces read as "premium" rather than as another primary action.
  // Identical in light and dark: it is a brand colour, not a surface.
  final Color pro; // Pro glyphs, selected plan ring, badges
  final Color onPro; // text & icons on top of the Pro gradient
  final Color proSubtle; // low-opacity purple for tinted icon chips
  final Color proGradientStart;
  final Color proGradientEnd;

  AppColorsExtension({
    required this.softBackground,
    required this.softButton,
    required this.success,
    required this.successContainer,
    required this.scaffoldBackground,
    required this.accent,
    required this.onAccent,
    required this.accentSubtle,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.pro,
    required this.onPro,
    required this.proSubtle,
    required this.proGradientStart,
    required this.proGradientEnd,
  });

  @override
  AppColorsExtension copyWith({
    Color? softBackground,
    Color? softButton,
    Color? success,
    Color? successContainer,
    Color? scaffoldBackground,
    Color? accent,
    Color? onAccent,
    Color? accentSubtle,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? pro,
    Color? onPro,
    Color? proSubtle,
    Color? proGradientStart,
    Color? proGradientEnd,
  }) {
    return AppColorsExtension(
      softBackground: softBackground ?? this.softBackground,
      softButton: softButton ?? this.softButton,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      pro: pro ?? this.pro,
      onPro: onPro ?? this.onPro,
      proSubtle: proSubtle ?? this.proSubtle,
      proGradientStart: proGradientStart ?? this.proGradientStart,
      proGradientEnd: proGradientEnd ?? this.proGradientEnd,
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
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSubtle: Color.lerp(accentSubtle, other.accentSubtle, t)!,
      heroGradientStart:
          Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      pro: Color.lerp(pro, other.pro, t)!,
      onPro: Color.lerp(onPro, other.onPro, t)!,
      proSubtle: Color.lerp(proSubtle, other.proSubtle, t)!,
      proGradientStart:
          Color.lerp(proGradientStart, other.proGradientStart, t)!,
      proGradientEnd: Color.lerp(proGradientEnd, other.proGradientEnd, t)!,
    );
  }
}
