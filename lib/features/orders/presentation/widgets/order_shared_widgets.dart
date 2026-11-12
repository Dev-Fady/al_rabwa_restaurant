import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/utils/number_format.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Date and time of an order, formatted with the app locale.
String? formatOrderDate(BuildContext context, DateTime? date) {
  if (date == null) return null;

  final local = date.toLocal();
  final localizations = MaterialLocalizations.of(context);
  final dateText = localizations.formatMediumDate(local);
  final timeText = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  return '$dateText • $timeText';
}

/// Round icon that reflects the order type (delivery, takeaway, dine-in).
class OrderTypeIcon extends StatelessWidget {
  const OrderTypeIcon({super.key, required this.type, this.size = 42});

  final String type;
  final double size;

  IconData get _icon => switch (type) {
    'delivery' => Icons.delivery_dining_rounded,
    'takeaway' => Icons.shopping_bag_rounded,
    'dine_in' => Icons.restaurant_rounded,
    _ => Icons.receipt_long_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final brand = context.appColors.brandGreen;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_icon, size: size / 2, color: brand),
    );
  }
}

/// Colored pill for an order or payment status.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.label, required this.value});

  final String label;
  final String value;

  Color _color(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return switch (value.toLowerCase()) {
      'pending' || 'new' || 'unpaid' => const Color(0xFFD97706),
      'preparing' ||
      'processing' ||
      'accepted' ||
      'confirmed' => const Color(0xFF2563EB),
      'ready' || 'out_for_delivery' => const Color(0xFF0D9488),
      'completed' || 'delivered' || 'paid' => context.appColors.brandGreen,
      'cancelled' || 'canceled' || 'rejected' || 'failed' => colors.error,
      _ => context.appColors.brandGreen,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Icon + text line used for addresses, tables and other order facts.
class OrderInfoLine extends StatelessWidget {
  const OrderInfoLine({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Compact icon + label chip.
class OrderInfoChip extends StatelessWidget {
  const OrderInfoChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label/value row used for customer and delivery details.
class OrderDetailRow extends StatelessWidget {
  const OrderDetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One ordered item with its quantity, options and price.
class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item, required this.currency});

  final OrderItem item;
  final StoreCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 48,
            height: 48,
            child: AppNetworkImage(
              url: item.image,
              width: 48,
              height: 48,
              fallbackIconSize: 20,
              fallbackColor: context.appColors.brandGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  Text(
                    currency.format(item.total),
                    style: TextStyle(
                      color: context.appColors.brandGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${formatWeightAmount(item.quantity)} × '
                '${currency.format(item.unitPrice)}',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.hasOptions) ...[
                const SizedBox(height: 2),
                Text(
                  item.options.join(' • '),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              if (item.hasAddons) ...[
                const SizedBox(height: 2),
                Text(
                  item.addons.join(' • '),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
              if (item.hasNote) ...[
                const SizedBox(height: 2),
                Text(
                  '${l10n.checkoutNotes}: ${item.note}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Highlighted note written by the customer.
class OrderNotesBox extends StatelessWidget {
  const OrderNotesBox({super.key, required this.label, required this.notes});

  final String label;
  final String notes;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.sticky_note_2_outlined, size: 16, color: brand),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: $notes',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One line of the order totals.
class OrderTotalRow extends StatelessWidget {
  const OrderTotalRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? colors.onSurface : colors.onSurfaceVariant,
              fontSize: isTotal ? 13.5 : 12.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color:
                  valueColor ??
                  (isTotal ? context.appColors.brandGreen : colors.onSurface),
              fontSize: isTotal ? 14.5 : 12.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
