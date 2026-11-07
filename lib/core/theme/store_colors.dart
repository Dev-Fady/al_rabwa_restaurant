import 'package:flutter/material.dart';

/// Theme-aware palette for the store surfaces (home, category products,
/// product details, favorites, categories).
///
/// The maroon/gold boutique look is preserved in both themes, but the accent
/// used for text and icons lightens in dark mode (deep maroon disappears on a
/// dark surface) and the beige/blush placeholder surfaces switch to warm dark
/// tones.
///
/// Access via `context.storeColors`.
@immutable
class StoreColors extends ThemeExtension<StoreColors> {
  const StoreColors({
    required this.accent,
    required this.maroon,
    required this.maroonDeep,
    required this.gold,
    required this.goldDeep,
    required this.blush,
    required this.photoBackground,
    required this.shimmerHighlight,
    required this.card,
    required this.ink,
    required this.muted,
    required this.divider,
    required this.tints,
  });

  /// Brand color for text and icons drawn on [card] or the screen background.
  final Color accent;

  /// Filled brand surfaces: badges, gradients and primary buttons.
  final Color maroon;
  final Color maroonDeep;

  final Color gold;
  final Color goldDeep;

  /// Soft brand tint behind category circles, chips and favorite buttons.
  final Color blush;

  /// Placeholder behind product photos while they load.
  final Color photoBackground;

  /// Highlight of the loading shimmer (the base is [photoBackground]).
  final Color shimmerHighlight;

  /// Card / elevated surface.
  final Color card;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color muted;

  /// Hairlines and dividers.
  final Color divider;

  /// Soft photo placeholders cycling across category cards.
  final List<Color> tints;

  static const light = StoreColors(
    accent: Color(0xFF7A1E2E),
    maroon: Color(0xFF7A1E2E),
    maroonDeep: Color(0xFF5E0C22),
    gold: Color(0xFFF3D9A4),
    goldDeep: Color(0xFFD9B98A),
    blush: Color(0xFFFBEBE8),
    photoBackground: Color(0xFFF3E9E4),
    shimmerHighlight: Colors.white,
    card: Colors.white,
    ink: Color(0xFF2B2B2B),
    muted: Color(0xFF6B7280),
    divider: Color(0xFFF0EAEC),
    tints: [
      Color(0xFFFFEDEF),
      Color(0xFFFBEFE3),
      Color(0xFFF2E9F4),
      Color(0xFFEAF4EC),
      Color(0xFFE9F1FA),
      Color(0xFFFFF4E0),
    ],
  );

  static const dark = StoreColors(
    accent: Color(0xFFE7B0B8),
    maroon: Color(0xFF7A1E2E),
    maroonDeep: Color(0xFF5E0C22),
    gold: Color(0xFFF3D9A4),
    goldDeep: Color(0xFFD9B98A),
    blush: Color(0xFF2C1E22),
    photoBackground: Color(0xFF272022),
    shimmerHighlight: Color(0xFF3B3033),
    card: Color(0xFF1E1E1E),
    ink: Color(0xFFF0F0F0),
    muted: Color(0xFF9CA3AF),
    divider: Color(0xFF3A3234),
    tints: [
      Color(0xFF2E2023),
      Color(0xFF2D2620),
      Color(0xFF29222C),
      Color(0xFF202A24),
      Color(0xFF1F2730),
      Color(0xFF2E2A20),
    ],
  );

  /// Palette for the current theme, with a brightness-based fallback for
  /// widgets pumped without the app theme (isolated widget tests).
  static StoreColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<StoreColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  StoreColors copyWith({
    Color? accent,
    Color? maroon,
    Color? maroonDeep,
    Color? gold,
    Color? goldDeep,
    Color? blush,
    Color? photoBackground,
    Color? shimmerHighlight,
    Color? card,
    Color? ink,
    Color? muted,
    Color? divider,
    List<Color>? tints,
  }) {
    return StoreColors(
      accent: accent ?? this.accent,
      maroon: maroon ?? this.maroon,
      maroonDeep: maroonDeep ?? this.maroonDeep,
      gold: gold ?? this.gold,
      goldDeep: goldDeep ?? this.goldDeep,
      blush: blush ?? this.blush,
      photoBackground: photoBackground ?? this.photoBackground,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      divider: divider ?? this.divider,
      tints: tints ?? this.tints,
    );
  }

  @override
  StoreColors lerp(StoreColors? other, double t) {
    if (other is! StoreColors) return this;
    return StoreColors(
      accent: Color.lerp(accent, other.accent, t)!,
      maroon: Color.lerp(maroon, other.maroon, t)!,
      maroonDeep: Color.lerp(maroonDeep, other.maroonDeep, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldDeep: Color.lerp(goldDeep, other.goldDeep, t)!,
      blush: Color.lerp(blush, other.blush, t)!,
      photoBackground: Color.lerp(photoBackground, other.photoBackground, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      tints: [
        for (var i = 0; i < tints.length; i++)
          Color.lerp(tints[i], other.tints[i % other.tints.length], t)!,
      ],
    );
  }
}

extension StoreColorsExtension on BuildContext {
  StoreColors get storeColors => StoreColors.of(this);
}
