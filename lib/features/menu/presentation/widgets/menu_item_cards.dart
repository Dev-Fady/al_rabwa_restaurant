import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/dish_add_control.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cards used by the three category display styles (`large`, `list`, `grid`).
class MenuDishLargeCard extends StatelessWidget {
  const MenuDishLargeCard({
    super.key,
    required this.item,
    required this.currency,
    this.quantity = 0,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  final MenuItem item;
  final StoreCurrency currency;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: _DishImage(url: item.image, iconSize: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DishName(item: item, color: colors.onSurface, fontSize: 16),
                if (item.hasDescription) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _DishPrice(
                        currency: currency,
                        item: item,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                    if (onAdd != null) ...[
                      const SizedBox(width: 8),
                      DishAddControl(
                        quantity: quantity,
                        onAdd: onAdd!,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuDishListTile extends StatelessWidget {
  const MenuDishListTile({
    super.key,
    required this.item,
    required this.currency,
    this.quantity = 0,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  final MenuItem item;
  final StoreCurrency currency;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: _DishImage(url: item.image, iconSize: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DishName(item: item, color: colors.onSurface, fontSize: 15),
                if (item.hasDescription) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _DishPrice(
                        currency: currency,
                        item: item,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                    if (onAdd != null) ...[
                      const SizedBox(width: 8),
                      DishAddControl(
                        quantity: quantity,
                        onAdd: onAdd!,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuDishGridCard extends StatelessWidget {
  const MenuDishGridCard({
    super.key,
    required this.item,
    required this.currency,
    this.quantity = 0,
    this.onAdd,
    this.onIncrement,
    this.onDecrement,
  });

  final MenuItem item;
  final StoreCurrency currency;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _DishImage(url: item.image, iconSize: 30),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DishName(item: item, color: colors.onSurface, fontSize: 13.5),
                const SizedBox(height: 8),
                _DishPrice(
                  currency: currency,
                  item: item,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                if (onAdd != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: DishAddControl(
                      quantity: quantity,
                      onAdd: onAdd!,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      buttonSize: 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DishName extends StatelessWidget {
  const _DishName({
    required this.item,
    required this.color,
    required this.fontSize,
  });

  final MenuItem item;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      item.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
    );
  }
}

class _DishPrice extends StatelessWidget {
  const _DishPrice({
    required this.currency,
    required this.item,
    this.crossAxisAlignment = CrossAxisAlignment.end,
  });

  final StoreCurrency currency;
  final MenuItem item;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          currency.format(item.price),
          textAlign: crossAxisAlignment == CrossAxisAlignment.start
              ? TextAlign.start
              : TextAlign.end,
          style: TextStyle(
            color: context.appColors.brandGreen,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (item.hasDiscount)
          Text(
            currency.format(item.compareAtPrice!),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _DishImage extends StatelessWidget {
  const _DishImage({required this.url, required this.iconSize});

  final String url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;

    if (url.trim().isEmpty) {
      return _DishImageFallback(brandColor: brandColor, iconSize: iconSize);
    }

    return AppNetworkImage(
      url: url,
      fit: BoxFit.cover,
      backgroundColor: colors.surface,
      fallbackColor: brandColor,
      fallbackIconSize: iconSize,
    );
  }
}

class _DishImageFallback extends StatelessWidget {
  const _DishImageFallback({required this.brandColor, required this.iconSize});

  final Color brandColor;
  final double iconSize;

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
        child: Icon(Icons.restaurant_menu, size: iconSize, color: brandColor),
      ),
    );
  }
}

/// Dishes sliver: picks the layout from the category's `display_style`.
class SliverMenuItems extends StatelessWidget {
  const SliverMenuItems({
    super.key,
    required this.status,
    required this.items,
    required this.displayStyle,
    required this.currency,
    required this.emptyMessage,
    required this.onRetry,
    required this.horizontalPadding,
    required this.gridColumns,
    this.onItemTap,
    this.quantityOf,
    this.onAddItem,
    this.onIncrementItem,
    this.onDecrementItem,
  });

  final MenuStatus status;
  final List<MenuItem> items;
  final CategoryDisplayStyle displayStyle;
  final StoreCurrency currency;
  final String emptyMessage;
  final VoidCallback onRetry;
  final double horizontalPadding;
  final int gridColumns;
  final ValueChanged<MenuItem>? onItemTap;
  final int Function(MenuItem item)? quantityOf;
  final ValueChanged<MenuItem>? onAddItem;
  final ValueChanged<MenuItem>? onIncrementItem;
  final ValueChanged<MenuItem>? onDecrementItem;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      horizontalPadding,
      16,
      horizontalPadding,
      28,
    );

    if (status == MenuStatus.loading) {
      return SliverPadding(
        padding: padding,
        sliver: const SliverToBoxAdapter(child: MenuItemsSkeleton()),
      );
    }

    if (status == MenuStatus.failure) {
      return SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: MenuErrorState(
            message: AppLocalizations.of(context)!.menuItemsError,
            onRetry: onRetry,
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: MenuEmptyState(message: emptyMessage),
        ),
      );
    }

    switch (displayStyle) {
      case CategoryDisplayStyle.large:
        return SliverPadding(
          padding: padding,
          sliver: SliverList.separated(
            itemCount: items.length,
            itemBuilder: (context, index) => _TapTarget(
              item: items[index],
              onItemTap: onItemTap,
              child: MenuDishLargeCard(
                key: ValueKey('menu-large-${items[index].id ?? index}'),
                item: items[index],
                currency: currency,
                quantity: quantityOf?.call(items[index]) ?? 0,
                onAdd: onAddItem == null
                    ? null
                    : () => onAddItem!(items[index]),
                onIncrement: onIncrementItem == null
                    ? null
                    : () => onIncrementItem!(items[index]),
                onDecrement: onDecrementItem == null
                    ? null
                    : () => onDecrementItem!(items[index]),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 14),
          ),
        );
      case CategoryDisplayStyle.list:
        return SliverPadding(
          padding: padding,
          sliver: SliverList.separated(
            itemCount: items.length,
            itemBuilder: (context, index) => _TapTarget(
              item: items[index],
              onItemTap: onItemTap,
              child: MenuDishListTile(
                key: ValueKey('menu-list-${items[index].id ?? index}'),
                item: items[index],
                currency: currency,
                quantity: quantityOf?.call(items[index]) ?? 0,
                onAdd: onAddItem == null
                    ? null
                    : () => onAddItem!(items[index]),
                onIncrement: onIncrementItem == null
                    ? null
                    : () => onIncrementItem!(items[index]),
                onDecrement: onDecrementItem == null
                    ? null
                    : () => onDecrementItem!(items[index]),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          ),
        );
      case CategoryDisplayStyle.grid:
        return SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final columns = gridColumns <= 0 ? 1 : gridColumns;
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      SizedBox(
                        width: cardWidth,
                        child: _TapTarget(
                          item: items[index],
                          onItemTap: onItemTap,
                          child: MenuDishGridCard(
                            key: ValueKey(
                              'menu-grid-${items[index].id ?? index}',
                            ),
                            item: items[index],
                            currency: currency,
                            quantity: quantityOf?.call(items[index]) ?? 0,
                            onAdd: onAddItem == null
                                ? null
                                : () => onAddItem!(items[index]),
                            onIncrement: onIncrementItem == null
                                ? null
                                : () => onIncrementItem!(items[index]),
                            onDecrement: onDecrementItem == null
                                ? null
                                : () => onDecrementItem!(items[index]),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
    }
  }
}

/// Makes a dish card open its details page while keeping the same look.
class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.item,
    required this.onItemTap,
    required this.child,
  });

  final MenuItem item;
  final ValueChanged<MenuItem>? onItemTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final onTap = onItemTap;
    if (onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onTap(item),
      child: child,
    );
  }
}

class MenuItemsSkeleton extends StatelessWidget {
  const MenuItemsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.35);

    return Column(
      children: [
        for (var index = 0; index < 3; index++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 104,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
      ],
    );
  }
}

class MenuErrorState extends StatelessWidget {
  const MenuErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class MenuEmptyState extends StatelessWidget {
  const MenuEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final colors = Theme.of(context).colorScheme;

  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );
}
