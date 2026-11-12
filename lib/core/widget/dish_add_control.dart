import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Green add button that turns into a −/quantity/+ pill once the dish is in
/// the cart.
class DishAddControl extends StatelessWidget {
  const DishAddControl({
    super.key,
    required this.quantity,
    required this.onAdd,
    this.onIncrement,
    this.onDecrement,
    this.buttonSize = 38,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = context.appColors.brandGreen;
    final colors = Theme.of(context).colorScheme;

    if (quantity <= 0) {
      return Semantics(
        button: true,
        label: l10n.addToCartLabel,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Material(
            color: brand,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onAdd,
              child: Icon(
                Icons.add,
                size: buttonSize * 0.55,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: buttonSize,
      padding: const EdgeInsetsDirectional.only(start: 3, end: 3),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(buttonSize),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            label: l10n.itemDetailsDecreaseQuantity,
            size: buttonSize * 0.78,
            onTap: onDecrement,
            brand: brand,
            iconColor: colors.onPrimary,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 24),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: brand,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            label: l10n.itemDetailsIncreaseQuantity,
            size: buttonSize * 0.78,
            onTap: onIncrement,
            brand: brand,
            iconColor: colors.onPrimary,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
    required this.brand,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final double size;
  final VoidCallback? onTap;
  final Color brand;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: onTap == null ? brand.withValues(alpha: 0.4) : brand,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, size: size * 0.55, color: iconColor),
          ),
        ),
      ),
    );
  }
}
