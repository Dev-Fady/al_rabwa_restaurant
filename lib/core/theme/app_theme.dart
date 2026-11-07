import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.light.brandGreen,
          brightness: Brightness.light,
          surface: AppColors.light.surface,
        ).copyWith(
          primary: AppColors.light.brandGreen,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFEDF6DA),
          onPrimaryContainer: AppColors.light.brandGreen,
          outlineVariant: const Color(0xFFECEBE3),
        );

    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.background,
        foregroundColor: AppColors.light.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.surface,
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
}
