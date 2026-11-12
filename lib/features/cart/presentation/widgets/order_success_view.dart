import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Confirmation shown after the backend creates the order.
class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({
    super.key,
    required this.order,
    required this.currency,
    required this.onDone,
  });

  final Order order;
  final StoreCurrency currency;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final number = order.displayNumber;
    final statusMessage = order.status.hasMessage
        ? order.status.message
        : l10n.checkoutOrderPlacedMessage;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.check_circle_rounded, size: 64, color: brand),
                  const SizedBox(height: 16),
                  Text(
                    l10n.checkoutOrderPlacedTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.appColors.titleColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  if (number != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.checkoutOrderNumber('$number'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (order.type.displayLabel.isNotEmpty)
                          _SuccessRow(
                            label: l10n.checkoutOrderType,
                            value: order.type.displayLabel,
                          ),
                        if (order.payment.displayMethod.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _SuccessRow(
                            label: l10n.checkoutPaymentMethod,
                            value: order.payment.displayMethod,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        _SuccessRow(
                          label: l10n.cartTotal,
                          value: currency.format(order.total),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onDone,
                    style: FilledButton.styleFrom(
                      backgroundColor: brand,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.checkoutDone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
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
              fontSize: isTotal ? 14 : 13,
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
              color: isTotal ? context.appColors.brandGreen : colors.onSurface,
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
