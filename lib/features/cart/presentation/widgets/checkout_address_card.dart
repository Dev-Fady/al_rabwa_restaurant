import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Selected delivery address preview card with change and add actions.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({
    super.key,
    required this.address,
    this.onChange,
    this.onAddAddress,
  });

  final Address address;
  final VoidCallback? onChange;
  final VoidCallback? onAddAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final summary = address.summary.trim();
    final showSummary = summary.isNotEmpty && summary != address.displayName;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brand.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, size: 19, color: brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            address.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: brand.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.addressDefault,
                              style: TextStyle(
                                color: brand,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (showSummary) ...[
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (!address.isDeliverable) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.checkoutAddressNotDeliverable,
                        style: TextStyle(
                          color: colors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (onChange != null || onAddAddress != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onAddAddress != null)
                  TextButton.icon(
                    onPressed: onAddAddress,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(l10n.addressAddTitle),
                    style: TextButton.styleFrom(
                      foregroundColor: brand,
                      minimumSize: const Size(48, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (onChange != null && onAddAddress != null)
                  const SizedBox(width: 8),
                if (onChange != null)
                  TextButton(
                    onPressed: onChange,
                    style: TextButton.styleFrom(
                      foregroundColor: brand,
                      minimumSize: const Size(48, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.checkoutChangeAddress),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
