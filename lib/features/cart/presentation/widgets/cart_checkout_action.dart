import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Checkout action shown below the cart summary.
class CartCheckoutAction extends StatelessWidget {
  const CartCheckoutAction({
    super.key,
    required this.enabled,
    required this.onCheckout,
  });

  final bool enabled;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return FilledButton.icon(
      onPressed: enabled ? onCheckout : null,
      icon: const Icon(Icons.shopping_cart_checkout_rounded),
      label: Text(l10n.checkoutTitle),
      style: FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: brand.withValues(alpha: 0.45),
        disabledForegroundColor: colors.onPrimary,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
