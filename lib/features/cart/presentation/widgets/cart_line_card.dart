import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/utils/number_format.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/core/widget/dish_add_control.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// One editable line of the cart: dish details, selections, notes, quantity
/// and the price calculated from the cart's own rules.
class CartLineCard extends StatelessWidget {
  const CartLineCard({
    super.key,
    required this.line,
    required this.currency,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartLine line;
  final StoreCurrency currency;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final item = line.item;
    final optionName = line.option?.name.trim() ?? '';
    final addonNames = [
      for (final addon in line.addons)
        if (addon.name.trim().isNotEmpty) addon.name.trim(),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 74,
              height: 74,
              child: AppNetworkImage(
                url: item.image,
                fallbackIconSize: 24,
                fallbackColor: context.appColors.brandGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currency.format(line.lineTotal),
                  style: TextStyle(
                    color: context.appColors.brandGreen,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (optionName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    optionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (addonNames.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    addonNames.join('، '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
                if (item.soldByWeight) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.itemDetailsWeightValue(
                      formatWeightAmount(line.weight),
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (line.hasNotes) ...[
                  const SizedBox(height: 4),
                  Text(
                    line.notes,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    DishAddControl(
                      quantity: line.quantity,
                      onAdd: onIncrement,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      buttonSize: 32,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      tooltip: l10n.cartRemoveItem,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colors.error,
                        size: 21,
                      ),
                    ),
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
