import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Top header matching the storefront design:
/// - Restaurant title (e.g. "مطعم الربوة")
/// - Language switcher toggle (عربي / EN)
/// - Restaurant logo badge
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.settings});

  final RestaurantSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final brandColor = context.appColors.titleColor;
    final restaurant = settings.restaurant;
    final title = restaurant.name.trim().isNotEmpty
        ? restaurant.name
        : l10n.appTitle;

    return Row(
      children: [
        // Title on the start side (in RTL this is on the right)
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: brandColor,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Language switcher pill
        const _LanguageSwitcherPill(),
        const SizedBox(width: 8),
        // Restaurant Logo
        _RestaurantLogoBadge(restaurant: restaurant),
      ],
    );
  }
}

class _LanguageSwitcherPill extends StatelessWidget {
  const _LanguageSwitcherPill();

  void _onSelect(BuildContext context, String langCode) {
    try {
      context.read<SettingsCubit>().changeLanguage(langCode);
    } catch (_) {
      // In isolated tests where SettingsCubit is not injected
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = context.appColors.brandGreen;
    final colors = Theme.of(context).colorScheme;
    final currentLocale = Localizations.localeOf(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Semantics(
      label: 'Change language',
      button: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.outlineVariant,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Icon(
              Icons.language,
              size: 18,
              color: brandColor,
            ),
            const SizedBox(width: 3),
            // Arabic option
            _LanguageOption(
              label: 'عربي',
              isSelected: isArabic,
              brandColor: brandColor,
              onTap: () {
                if (!isArabic) {
                  _onSelect(context, 'ar');
                }
              },
            ),
            const SizedBox(width: 2),
            // English option
            _LanguageOption(
              label: 'EN',
              isSelected: !isArabic,
              brandColor: brandColor,
              onTap: () {
                if (isArabic) {
                  _onSelect(context, 'en');
                }
              },
            ),
            const SizedBox(width: 3),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.brandColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color brandColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
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

class _RestaurantLogoBadge extends StatelessWidget {
  const _RestaurantLogoBadge({required this.restaurant});

  final RestaurantBrand restaurant;

  @override
  Widget build(BuildContext context) {
    final brandColor = context.appColors.brandGreen;

    return Semantics(
      label: restaurant.name,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: brandColor,
          borderRadius: BorderRadius.circular(12),
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
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                backgroundColor: brandColor,
                fallbackColor: Theme.of(context).colorScheme.surface,
                fallbackIconSize: 20,
              )
            : Center(
                child: Icon(
                  Icons.restaurant,
                  size: 22,
                  color: context.appColors.accent,
                ),
              ),
      ),
    );
  }
}
