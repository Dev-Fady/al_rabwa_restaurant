import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Highlighted banner for the selected category: name and item count on the
/// start side, a rounded category photo on the end side.
class MenuCategoryHero extends StatelessWidget {
  const MenuCategoryHero({
    super.key,
    required this.category,
    required this.fallbackImage,
    required this.itemsCount,
  });

  final MenuCategory category;

  /// Used when the category itself has no image yet (the live API returns
  /// `null` for every category), e.g. the first dish photo.
  final String fallbackImage;

  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = context.appColors.accent;
    final brandColor = context.appColors.brandGreen;
    final l10n = AppLocalizations.of(context)!;
    final image = category.image.trim().isNotEmpty
        ? category.image
        : fallbackImage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.18), colors.surface),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: brandColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.menuItemsCount(itemsCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 92,
              height: 92,
              child: image.isNotEmpty
                  ? AppNetworkImage(
                      url: image,
                      fit: BoxFit.cover,
                      backgroundColor: colors.surface,
                      fallbackColor: brandColor,
                      fallbackIconSize: 28,
                    )
                  : _HeroImageFallback(brandColor: brandColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback({required this.brandColor});

  final Color brandColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            brandColor.withValues(alpha: 0.14),
            brandColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.restaurant_menu, size: 30, color: brandColor),
      ),
    );
  }
}
