import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/utils/number_format.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_line.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Read-only cart line shown before placing an order.
class CheckoutLineTile extends StatelessWidget {
  const CheckoutLineTile({
    super.key,
    required this.line,
    required this.currency,
  });

  final CartLine line;
  final StoreCurrency currency;

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 62,
              height: 62,
              child: AppNetworkImage(
                url: item.image,
                fallbackIconSize: 22,
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
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currency.format(line.lineTotal),
                  style: TextStyle(
                    color: context.appColors.brandGreen,
                    fontSize: 14,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${l10n.itemDetailsQuantity}: ${line.quantity}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
