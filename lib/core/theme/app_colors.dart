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
    required this.background,
    required this.surface,
    required this.textPrimary,
  });

  /// Primary brand green used for seeds, titles and selected controls.
  final Color brandGreen;
  final Color background;
  final Color surface;
  final Color textPrimary;

  static const light = AppColors(
    brandGreen: Color(0xFF0F3B1C),
    background: Color(0xFFFBFAF6),
    surface: Colors.white,
    textPrimary: Color(0xFF1D2A1E),
  );

  static const dark = AppColors(
    brandGreen: Color(0xFF8FD96B),
    background: Color(0xFF0F1410),
    surface: Color(0xFF1A211B),
    textPrimary: Color(0xFFF2F5F0),
  );

  @override
  AppColors copyWith({
    Color? brandGreen,
    Color? background,
    Color? surface,
    Color? textPrimary,
  }) {
    return AppColors(
      brandGreen: brandGreen ?? this.brandGreen,
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
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
