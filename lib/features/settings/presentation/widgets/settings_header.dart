import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:flutter/material.dart';

/// Centered restaurant identity at the top of the store tab.
///
/// Mirrors the storefront "about" page: rounded logo, restaurant name and the
/// tagline/description below it. Everything comes from `GET /api/settings`.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.restaurant,
    this.fallbackName,
  });

  final RestaurantBrand restaurant;

  /// Shown when the backend does not provide a restaurant name.
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = context.appColors.titleColor;
    final name = restaurant.name.trim().isNotEmpty
        ? restaurant.name
        : (fallbackName ?? '');
    final about = restaurant.about.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RestaurantLogo(restaurant: restaurant),
          const SizedBox(height: 10),
          if (name.isNotEmpty)
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: titleColor,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          if (about.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              about,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo({required this.restaurant});

  /// Matches the storefront's 96px rounded logo badge.
  static const double _size = 96;
  // static const double _radius = 20;

  final RestaurantBrand restaurant;

  @override
  Widget build(BuildContext context) {
    final l10nName = restaurant.name.trim();

    return Semantics(
      image: true,
      label: l10nName,
      child: Container(
        width: _size,
        height: _size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.white,
          // borderRadius: BorderRadius.circular(_radius),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0x1A000000),
          //     blurRadius: 24,
          //     offset: Offset(0, 8),
          //   ),
          // ],
        ),
        clipBehavior: Clip.antiAlias,
        child: restaurant.hasLogo
            ? AppNetworkImage(
                url: restaurant.logo,
                width: _size,
                height: _size,
                fit: BoxFit.contain,
                backgroundColor: Colors.white,
                fallbackColor: context.appColors.brandGreen,
                fallbackIconSize: 40,
              )
            : Icon(
                Icons.restaurant,
                size: 42,
                color: context.appColors.brandGreen,
              ),
      ),
    );
  }
}
