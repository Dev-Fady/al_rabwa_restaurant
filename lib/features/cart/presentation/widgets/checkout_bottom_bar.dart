import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Sticky total + place-order action at the bottom of checkout.
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.total,
    required this.currency,
    required this.enabled,
    required this.submitting,
    required this.onSubmit,
    this.summary,
  });

  final double total;
  final StoreCurrency currency;
  final bool enabled;
  final bool submitting;
  final VoidCallback onSubmit;

  /// Order type and payment summary shown on wider layouts.
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final showSummary =
                !compact && (summary?.trim().isNotEmpty ?? false);
            final totalBlock = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cartTotal,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  currency.format(total),
                  style: TextStyle(
                    color: brand,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showSummary) ...[
                  const SizedBox(height: 2),
                  Text(
                    summary!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );

            final button = FilledButton(
              onPressed: enabled && !submitting ? onSubmit : null,
              style: FilledButton.styleFrom(
                backgroundColor: brand,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: brand.withValues(alpha: 0.45),
                disabledForegroundColor: colors.onPrimary,
                minimumSize: const Size(0, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: submitting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(child: Text(l10n.checkoutSubmitting)),
                      ],
                    )
                  : Text(l10n.checkoutPlaceOrder),
            );

            if (compact) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [totalBlock, const SizedBox(height: 10), button],
              );
            }

            return Row(
              children: [
                Expanded(child: totalBlock),
                const SizedBox(width: 16),
                Flexible(child: button),
              ],
            );
          },
        ),
      ),
    );
  }
}
