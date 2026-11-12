import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Server-authoritative cart totals, with a local subtotal fallback while the
/// quote loads or when the request fails without a cached copy.
class CartQuoteSummary extends StatelessWidget {
  const CartQuoteSummary({
    super.key,
    required this.cart,
    required this.state,
    required this.currency,
    required this.onRetry,
  });

  final Cart cart;
  final CartQuoteState state;
  final StoreCurrency currency;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final quote = state.quote;
    final subtotal = quote?.subtotal ?? cart.subtotal;
    final total = quote?.total ?? cart.subtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.cartSummaryTitle,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (state.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: l10n.cartSubtotal,
            value: currency.format(subtotal),
          ),
          if (quote != null && quote.hasDiscount) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: quote.coupon?.hasCode == true
                  ? '${l10n.cartDiscount} (${quote.coupon!.code})'
                  : l10n.cartDiscount,
              value: '-${currency.format(quote.discount)}',
              valueColor: colors.error,
            ),
          ],
          if (quote != null && quote.hasTax) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.taxLabel,
              value: currency.format(quote.tax),
            ),
          ],
          if (quote != null && quote.hasServiceCharge) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.serviceLabel,
              value: currency.format(quote.serviceCharge),
            ),
          ],
          if (quote != null && quote.hasDeliveryFee) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.deliveryFeeLabel,
              value: currency.format(quote.deliveryFee),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _SummaryRow(
            label: l10n.cartTotal,
            value: currency.format(total),
            isTotal: true,
          ),
          if (state.isLoading && quote == null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.cartQuoteLoading,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
            ),
          ],
          if (quote?.isClosed == true) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.lock_clock_outlined,
              message: quote!.closedMessage.trim().isNotEmpty
                  ? quote.closedMessage
                  : l10n.storeClosed,
              color: colors.error,
            ),
          ],
          if (quote?.addressRequired == true) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.location_on_outlined,
              message: l10n.cartAddressRequired,
              color: context.appColors.brandGreen,
            ),
          ],
          if (state.hasError) ...[
            const SizedBox(height: 12),
            _Notice(
              icon: Icons.cloud_off_outlined,
              message: state.isFromCache
                  ? l10n.cartQuoteCached
                  : l10n.cartQuoteError,
              color: colors.error,
              action: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.brandGreen,
                  minimumSize: const Size(48, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.retry),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
              fontSize: isTotal ? 15 : 13.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color:
                valueColor ??
                (isTotal ? context.appColors.brandGreen : colors.onSurface),
            fontSize: isTotal ? 16 : 13.5,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.message,
    required this.color,
    this.action,
  });

  final IconData icon;
  final String message;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12.5, height: 1.35),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
