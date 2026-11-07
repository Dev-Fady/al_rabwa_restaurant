import 'package:flutter/material.dart';

/// Core shared color tokens.
///
/// Access via `context.appColors`.
/// Feature-specific colors live in their own ThemeExtension classes:
/// [DrawerColors], [NavigationColors], [GiftColors], [ProfileColors],
/// [NotificationColors], [GreetingColors].
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brandPink,
    required this.background,
    required this.surface,
    required this.textPrimary,
  });

  final Color brandPink;
  final Color background;
  final Color surface;
  final Color textPrimary;

  @override
  AppColors copyWith({
    Color? brandPink,
    Color? background,
    Color? surface,
    Color? textPrimary,
  }) {
    return AppColors(
      brandPink: brandPink ?? this.brandPink,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandPink: Color.lerp(brandPink, other.brandPink, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
