import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.light.brandPink,
        brightness: Brightness.light,
        surface: AppColors.light.surface,
      ),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // backgroundColor: NavigationColors.light.barBackground,
        // selectedItemColor: NavigationColors.light.itemActive,
        // unselectedItemColor: NavigationColors.light.itemInactive,
      ),
      extensions: const [AppColors.light, StoreColors.light],
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.dark.brandPink,
        brightness: Brightness.dark,
        surface: AppColors.dark.surface,
      ),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // backgroundColor: NavigationColors.dark.barBackground,
        // selectedItemColor: NavigationColors.dark.itemActive,
        // unselectedItemColor: NavigationColors.dark.itemInactive,
      ),
      extensions: const [AppColors.dark, StoreColors.dark],
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
    );
  }
}
