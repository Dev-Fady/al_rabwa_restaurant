import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart' as l10n;
import 'package:flutter/material.dart';

/// Segmented menu-language picker used on the store tab.
///
/// Options come from [RestaurantSettings.localization.locales]; the selected
/// language follows the app locale. Switching reloads the storefront settings
/// for the new language through `SettingsCubit`.
class SettingsLanguageSelector extends StatelessWidget {
  const SettingsLanguageSelector({
    super.key,
    required this.locales,
    required this.onChanged,
  });

  final List<String> locales;
  final ValueChanged<String> onChanged;

  static const double _outerPadding = 3;
  static const double _segmentGap = 4;
  static const double _outerRadius = 18;
  static const double _segmentRadius = 15;
  static const double _minSegmentHeight = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appLocalizations = l10n.AppLocalizations.of(context)!;

    // Keep the backend order but drop blanks/duplicates.
    final codes = <String>[];
    for (final code in locales) {
      final trimmed = code.trim();
      if (trimmed.isEmpty || codes.contains(trimmed)) continue;
      codes.add(trimmed);
    }
    if (codes.isEmpty) return const SizedBox.shrink();

    final current = Localizations.localeOf(context).languageCode;
    final background = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.035),
      scheme.surface,
    );

    return Semantics(
      label: appLocalizations.storeLanguageTitle,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(_outerPadding),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(_outerRadius),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < codes.length; i++) ...[
                if (i > 0) const SizedBox(width: _segmentGap),
                Expanded(
                  child: _LanguageSegment(
                    label: _labelFor(codes[i], appLocalizations),
                    isSelected: codes[i] == current,
                    onTap: codes[i] == current
                        ? null
                        : () => onChanged(codes[i]),
                    radius: _segmentRadius,
                    minHeight: _minSegmentHeight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Language names stay in their own script, like the storefront's picker.
  static String _labelFor(String code, l10n.AppLocalizations appLocalizations) {
    return switch (code) {
      'ar' => appLocalizations.storeLanguageArabic,
      'en' => appLocalizations.storeLanguageEnglish,
      _ => code.toUpperCase(),
    };
  }
}

class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.radius,
    required this.minHeight,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double radius;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final primary = context.appColors.brandGreen;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.14),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
