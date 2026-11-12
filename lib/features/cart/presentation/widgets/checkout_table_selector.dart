import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_notice.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Dine-in table picker. The customer must choose explicitly so an order is
/// never sent to the wrong table.
class CheckoutTableSelector extends StatelessWidget {
  const CheckoutTableSelector({
    super.key,
    required this.tables,
    required this.selectedTable,
    required this.loading,
    required this.error,
    required this.onChanged,
    required this.onRetry,
  });

  final List<DiningTable> tables;
  final DiningTable? selectedTable;
  final bool loading;
  final String? error;
  final ValueChanged<DiningTable> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (loading && tables.isEmpty) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.checkoutTableLoading,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      );
    }

    if (tables.isEmpty) {
      return CheckoutNotice(
        icon: Icons.table_restaurant_outlined,
        message: error?.trim().isNotEmpty == true
            ? error!.trim()
            : l10n.checkoutNoTables,
        color: colors.error,
        action: error == null
            ? null
            : TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.brandGreen,
                  minimumSize: const Size(48, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l10n.retry),
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedTable?.id,
              isExpanded: true,
              isDense: true,
              hint: Text(l10n.checkoutChooseTable),
              items: [
                for (final table in tables)
                  DropdownMenuItem(
                    value: table.id,
                    child: Text(
                      table.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                if (id == null) return;
                for (final table in tables) {
                  if (table.id == id) {
                    onChanged(table);
                    return;
                  }
                }
              },
            ),
          ),
        ),
        if (selectedTable == null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.checkoutTableRequired,
            style: TextStyle(
              color: colors.error,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 10),
          CheckoutNotice(
            icon: Icons.cloud_off_outlined,
            message: error!.trim().isNotEmpty
                ? error!.trim()
                : l10n.checkoutTableError,
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
    );
  }
}
