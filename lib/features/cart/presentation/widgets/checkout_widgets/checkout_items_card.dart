import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_line_tile.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Card listing the cart lines with an action to edit the cart.
class CheckoutItemsCard extends StatelessWidget {
  const CheckoutItemsCard({
    super.key,
    required this.cart,
    required this.currency,
    required this.onEditCart,
  });

  final Cart cart;
  final StoreCurrency currency;
  final VoidCallback onEditCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
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
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: brand,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkoutItems,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.menuItemsCount(cart.itemsCount),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEditCart,
                tooltip: l10n.checkoutEditCart,
                icon: const Icon(Icons.edit_outlined, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: brand,
                  backgroundColor: brand.withValues(alpha: 0.10),
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var index = 0; index < cart.lines.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.6),
              ),
            CheckoutLineTile(line: cart.lines[index], currency: currency),
          ],
        ],
      ),
    );
  }
}
