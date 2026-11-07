import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Dark green bar that summarises the cart and opens it.
///
/// Sits above the shell's bottom navigation when the cart is not empty.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.itemsLabel,
    required this.totalLabel,
    required this.onViewCart,
  });

  final String itemsLabel;
  final String totalLabel;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = context.appColors.brandGreen;
    final onBrand = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: brand,
          child: InkWell(
            onTap: onViewCart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 20, color: onBrand),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 4,
                    child: Text(
                      itemsLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onBrand,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      l10n.viewCart,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onBrand,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      totalLabel,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onBrand,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
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
