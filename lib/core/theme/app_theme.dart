import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  /// Accent used when the backend does not provide one.
  static const Color _defaultAccent = Color(0xFFC7DF39);

  /// Builds the light theme from the restaurant's brand colors.
  ///
  /// Every argument is the raw hex string returned by `GET /api/settings`;
  /// null/blank/invalid values fall back to the default restaurant palette so
  /// the app still renders before the settings request finishes.
  static ThemeData light({
    String? primaryHex,
    String? accentHex,
    String? backgroundHex,
    String? textHex,
    String? titleHex,
  }) {
    final primary = _hexOr(primaryHex, AppColors.light.brandGreen);
    final accent = _hexOr(accentHex, _defaultAccent);
    final background = _hexOr(backgroundHex, AppColors.light.background);
    final text = _hexOr(textHex, AppColors.light.textPrimary);
    final title = _hexOr(titleHex, primary);

    final onPrimary = _onColor(primary);
    final surface = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.72),
      background,
    );
    final primaryContainer = Color.alphaBlend(
      accent.withValues(alpha: 0.22),
      Colors.white,
    );
    final outlineVariant = Color.lerp(background, text, 0.12)!;
    final onSurfaceVariant = Color.lerp(text, background, 0.38)!;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: primary,
          secondary: accent,
          onSecondary: _onColor(accent),
          tertiary: accent,
          onTertiary: _onColor(accent),
          surface: surface,
          onSurface: text,
          onSurfaceVariant: onSurfaceVariant,
          outlineVariant: outlineVariant,
        );

    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        titleTextStyle: _titleStyle(title),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: const [AppColors.light, StoreColors.light],
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.dark.brandGreen,
          brightness: Brightness.dark,
          surface: AppColors.dark.surface,
        ).copyWith(
          primary: AppColors.dark.brandGreen,
          onPrimary: const Color(0xFF0F1410),
          primaryContainer: const Color(0xFF26331F),
          onPrimaryContainer: AppColors.dark.brandGreen,
          outlineVariant: const Color(0xFF2C352C),
        );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.background,
        foregroundColor: AppColors.dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      extensions: const [AppColors.dark, StoreColors.dark],
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );
  }

  static TextStyle _titleStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// `#RGB`, `#RRGGBB` and `#AARRGGBB` (with or without `#`).
  static Color _hexOr(String? value, Color fallback) {
    final parsed = parseHexColor(value);
    return parsed ?? fallback;
  }

  /// Parses a backend hex color, returning null for blank/invalid values.
  static Color? parseHexColor(String? value) {
    var hex = value?.trim() ?? '';
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    if (hex.length == 6) {
      final rgb = int.tryParse(hex, radix: 16);
      return rgb == null ? null : Color(0xFF000000 | rgb);
    }
    if (hex.length == 8) {
      final argb = int.tryParse(hex, radix: 16);
      return argb == null ? null : Color(argb);
    }
    return null;
  }

  /// Black or white, whichever is readable on [color].
  static Color _onColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF161A17);
  }
}
