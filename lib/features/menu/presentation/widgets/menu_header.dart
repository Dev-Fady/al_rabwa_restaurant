import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Menu page header: title + restaurant name on the start side, language
/// switcher and logo on the end side.
class MenuHeader extends StatelessWidget {
  const MenuHeader({
    super.key,
    required this.restaurant,
    required this.restaurantName,
  });

  final RestaurantBrand restaurant;
  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.menuTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: context.appColors.brandGreen,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              restaurantName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _MenuLanguagePill(),
            const SizedBox(width: 8),
            _MenuLogoBadge(restaurant: restaurant),
          ],
        ),
      ],
    );
  }
}

class _MenuLanguagePill extends StatelessWidget {
  const _MenuLanguagePill();

  void _select(BuildContext context, String langCode) {
    try {
      context.read<SettingsCubit>().changeLanguage(langCode);
    } catch (_) {
      // In isolated tests where SettingsCubit is not injected.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Semantics(
      button: true,
      label: '${l10n.arabic} / ${l10n.english}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: 18, color: brandColor),
            const SizedBox(width: 4),
            _LanguageChoice(
              label: l10n.arabic,
              selected: isArabic,
              onTap: () {
                if (!isArabic) _select(context, 'ar');
              },
            ),
            const SizedBox(width: 2),
            _LanguageChoice(
              label: l10n.english,
              selected: !isArabic,
              onTap: () {
                if (isArabic) _select(context, 'en');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brandColor = context.appColors.brandGreen;
    final colors = Theme.of(context).colorScheme;

    if (selected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colors.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            color: brandColor.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _MenuLogoBadge extends StatelessWidget {
  const _MenuLogoBadge({required this.restaurant});

  final RestaurantBrand restaurant;

  @override
  Widget build(BuildContext context) {
    final brandColor = context.appColors.brandGreen;

    return Semantics(
      label: restaurant.name,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: brandColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: restaurant.hasLogo
            ? AppNetworkImage(
                url: restaurant.logo,
                fit: BoxFit.cover,
                backgroundColor: brandColor,
                fallbackColor: Theme.of(context).colorScheme.surface,
                fallbackIconSize: 22,
              )
            : Center(
                child: Icon(
                  Icons.restaurant,
                  size: 24,
                  color: context.appColors.accent,
                ),
              ),
      ),
    );
  }
}
