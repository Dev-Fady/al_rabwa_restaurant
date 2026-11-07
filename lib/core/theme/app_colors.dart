import 'package:flutter/material.dart';

/// Core shared color tokens.
///
/// Access via `context.appColors`.
/// Feature-specific colors live in their own ThemeExtension classes:
/// [DrawerColors], [NavigationColors], [GiftColors], [ProfileColors],
/// [NotificationColors], [GreetingColors].
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandGreen,
    required this.accent,
    required this.titleColor,
    required this.background,
    required this.surface,
    required this.textPrimary,
  });

  /// Primary brand green used for seeds, titles and selected controls.
  final Color brandGreen;

  /// Secondary/lime accent from the backend theme.
  final Color accent;

  /// Heading color from the backend theme (`title_color`).
  final Color titleColor;

  final Color background;
  final Color surface;
  final Color textPrimary;

  static const light = AppColors(
    brandGreen: Color(0xFF174722),
    accent: Color(0xFFC7DF39),
    titleColor: Color(0xFF174722),
    background: Color(0xFFFAF9F5),
    surface: Colors.white,
    textPrimary: Color(0xFF161A17),
  );

  static const dark = AppColors(
    brandGreen: Color(0xFF8FD96B),
    accent: Color(0xFFC7DF39),
    titleColor: Color(0xFFF2F5F0),
    background: Color(0xFF0F1410),
    surface: Color(0xFF1A211B),
    textPrimary: Color(0xFFF2F5F0),
  );

  @override
  AppColors copyWith({
    Color? brandGreen,
    Color? accent,
    Color? titleColor,
    Color? background,
    Color? surface,
    Color? textPrimary,
  }) {
    return AppColors(
      brandGreen: brandGreen ?? this.brandGreen,
      accent: accent ?? this.accent,
      titleColor: titleColor ?? this.titleColor,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandGreen: Color.lerp(brandGreen, other.brandGreen, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
