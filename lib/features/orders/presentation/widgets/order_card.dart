import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/widgets/order_shared_widgets.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// One order in the order history.
///
/// The card is a compact summary; tapping it opens the full order page.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.currency,
    this.onTap,
  });

  final Order order;
  final StoreCurrency currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final number = order.displayNumber;
    final date = formatOrderDate(context, order.createdAt);
    final typeLabel = order.type.displayLabel;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderTypeIcon(type: order.type.value),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                number == null
                                    ? l10n.navOrders
                                    : l10n.checkoutOrderNumber('$number'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.appColors.titleColor,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (order.status.displayLabel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: OrderStatusBadge(
                                  label: order.status.displayLabel,
                                  value: order.status.value,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (typeLabel.isNotEmpty || date != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (typeLabel.isNotEmpty) typeLabel,
                              ?date,
                            ].join(' • '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (order.hasTable || order.hasAddress) ...[
                const SizedBox(height: 10),
                if (order.hasTable)
                  OrderInfoLine(
                    icon: Icons.table_restaurant_outlined,
                    text: '${l10n.checkoutTable}: ${order.table}',
                  ),
                if (order.hasAddress)
                  OrderInfoLine(
                    icon: Icons.location_on_outlined,
                    text: order.address!.summary,
                  ),
              ],
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    l10n.menuItemsCount(order.items.length),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    currency.format(order.total),
                    style: TextStyle(
                      color: context.appColors.brandGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: [
                  Text(
                    l10n.ordersShowDetails,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appColors.brandGreen,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(
                    isRtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 19,
                    color: context.appColors.brandGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
