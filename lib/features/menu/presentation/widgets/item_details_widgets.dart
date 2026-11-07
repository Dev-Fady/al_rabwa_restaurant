import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Plus/minus control used on the dish details page.
class ItemQuantityStepper extends StatelessWidget {
  const ItemQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.maxQuantity = 99,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int maxQuantity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canDecrease = quantity > 1;
    final canIncrease = quantity < maxQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          label: l10n.itemDetailsDecreaseQuantity,
          filled: false,
          onPressed: canDecrease ? () => onChanged(quantity - 1) : null,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 46),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          label: l10n.itemDetailsIncreaseQuantity,
          filled: true,
          onPressed: canIncrease ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final enabled = onPressed != null;

    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        backgroundColor: filled && enabled ? brand : colors.surface,
        foregroundColor: filled && enabled ? colors.onPrimary : brand,
        disabledForegroundColor: colors.onSurfaceVariant.withValues(
          alpha: 0.45,
        ),
        side: BorderSide(
          color: filled
              ? Colors.transparent
              : colors.outlineVariant.withValues(alpha: enabled ? 1 : 0.5),
        ),
      ),
    );
  }
}

/// Full-bleed dish photo with a branded fallback when there is no image.
class ItemHeroImage extends StatelessWidget {
  const ItemHeroImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    if (url.trim().isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              brand.withValues(alpha: 0.18),
              brand.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: Center(
          child: Icon(Icons.restaurant_menu, size: 56, color: brand),
        ),
      );
    }

    return AppNetworkImage(
      url: url,
      fit: BoxFit.cover,
      backgroundColor: colors.surface,
      fallbackColor: brand,
      fallbackIconSize: 48,
    );
  }
}

/// Circular back control that stays readable on top of the dish photo.
class ItemBackButton extends StatelessWidget {
  const ItemBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Material(
      color: colors.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: AppLocalizations.of(context)!.backLabel,
        icon: Icon(Icons.arrow_back_ios_new, size: 18, color: brand),
      ),
    );
  }
}
