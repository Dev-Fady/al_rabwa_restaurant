import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:flutter/material.dart';

/// Responsive card grid used by the "أقسام المنيو" page.
///
/// The number of columns follows the available width (2 on phones, more on
/// tablets/desktop) and each card grows with its own text so long localized
/// names and large text scales never overflow.
class MenuCategoriesGrid extends StatelessWidget {
  const MenuCategoriesGrid({
    super.key,
    required this.categories,
    required this.itemsLabel,
    required this.onCategoryTap,
  });

  final List<MenuCategory> categories;

  /// Localized item count for a category, e.g. "5 أصناف".
  final String Function(MenuCategory category) itemsLabel;

  final ValueChanged<MenuCategory> onCategoryTap;

  static const double _spacing = 12;

  static int columnsFor(double width) {
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (var index = 0; index < categories.length; index++)
              SizedBox(
                width: cardWidth,
                child: MenuCategoryCard(
                  key: ValueKey(
                    'menu-category-card-${categories[index].id ?? index}',
                  ),
                  category: categories[index],
                  itemsLabel: itemsLabel(categories[index]),
                  onTap: () => onCategoryTap(categories[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// White card with the category photo on top and its name/item count below.
class MenuCategoryCard extends StatelessWidget {
  const MenuCategoryCard({
    super.key,
    required this.category,
    required this.itemsLabel,
    required this.onTap,
  });

  final MenuCategory category;
  final String itemsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final borderRadius = BorderRadius.circular(20);

    return Semantics(
      button: true,
      label: '${category.name}، $itemsLabel',
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.8)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: _CategoryImage(category: category),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemsLabel,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.category});

  final MenuCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;

    if (!category.hasImage) {
      return _CategoryImageFallback(brandColor: brandColor);
    }

    return AppNetworkImage(
      url: category.image,
      fit: BoxFit.cover,
      backgroundColor: colors.surface,
      fallbackColor: brandColor,
      fallbackIconSize: 30,
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback({required this.brandColor});

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

/// Placeholder grid shown while the sections are loading.
class MenuCategoriesGridSkeleton extends StatelessWidget {
  const MenuCategoriesGridSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.35);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = MenuCategoriesGrid.columnsFor(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth -
                MenuCategoriesGrid._spacing * (columns - 1)) /
            columns;

        return Wrap(
          spacing: MenuCategoriesGrid._spacing,
          runSpacing: MenuCategoriesGrid._spacing,
          children: [
            for (var index = 0; index < count; index++)
              SizedBox(
                width: cardWidth,
                child: Container(
                  height: cardWidth * 0.78,
                  decoration: BoxDecoration(
                    color: placeholder,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
