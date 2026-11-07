import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:flutter/material.dart';

/// Horizontal category selector: the selected category is a filled dark-green
/// pill, the rest are outlined pills.
class MenuCategoryTabs extends StatelessWidget {
  const MenuCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.horizontalPadding,
  });

  final List<MenuCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<MenuCategory> onSelected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            _CategoryTab(
              category: categories[index],
              selected: categories[index].id == selectedCategoryId,
              onTap: () => onSelected(categories[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final MenuCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;
    final borderRadius = BorderRadius.circular(14);

    return Semantics(
      button: true,
      selected: selected,
      label: category.name,
      child: Material(
        color: selected ? brandColor : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: selected ? brandColor : colors.outlineVariant,
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            alignment: Alignment.center,
            child: Text(
              category.name,
              softWrap: false,
              style: TextStyle(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
