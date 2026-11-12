import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/checkout_state.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_notice.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/widgets/checkout_widgets/checkout_helpers.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Delivery address picker shown in the checkout form.
class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({
    super.key,
    required this.checkoutState,
    required this.onSelectAddress,
    required this.onAddNewAddress,
    required this.onPickAddress,
    required this.onRetryAddresses,
  });

  final CheckoutState checkoutState;
  final ValueChanged<Address> onSelectAddress;
  final VoidCallback onAddNewAddress;
  final VoidCallback onPickAddress;
  final VoidCallback onRetryAddresses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final addresses = checkoutState.addresses;
    final selectedAddress = checkoutState.selectedAddress;

    if (checkoutState.isLoadingAddresses && addresses.isEmpty) {
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
              l10n.checkoutAddressLoading,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          ),
        ],
      );
    }

    if (addresses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onAddNewAddress,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(l10n.addressAddTitle),
            style: OutlinedButton.styleFrom(
              foregroundColor: brand,
              side: BorderSide(color: brand.withValues(alpha: 0.5)),
              minimumSize: const Size(double.infinity, 48),
              alignment: AlignmentDirectional.centerStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.checkoutNoAddress,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          if (checkoutState.hasAddressError) ...[
            const SizedBox(height: 10),
            CheckoutNotice(
              icon: Icons.cloud_off_outlined,
              message: (checkoutState.addressError?.trim().isNotEmpty ?? false)
                  ? checkoutState.addressError!.trim()
                  : l10n.checkoutAddressError,
              color: colors.error,
              action: TextButton(
                onPressed: onRetryAddresses,
                style: TextButton.styleFrom(
                  foregroundColor: brand,
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

    final hasSelected = addresses.any((a) => a.id == selectedAddress?.id);
    final dropdownValue = hasSelected ? selectedAddress?.id : null;

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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: dropdownValue,
              isExpanded: true,
              isDense: true,
              hint: Text(l10n.checkoutChooseAddress),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: brand,
                size: 24,
              ),
              items: [
                for (final addr in addresses)
                  DropdownMenuItem<int>(
                    value: addr.id,
                    child: Row(
                      children: [
                        Icon(
                          checkoutAddressIcon(addr.kind),
                          size: 18,
                          color: addr.id == selectedAddress?.id
                              ? brand
                              : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            addr.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: addr.id == selectedAddress?.id
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: brand.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.addressDefault,
                              style: TextStyle(
                                color: brand,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                DropdownMenuItem<int>(
                  value: -1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: brand,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.addressAddTitle,
                        style: TextStyle(
                          color: brand,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == -1) {
                  onAddNewAddress();
                } else if (value != null) {
                  final picked = addresses.firstWhere((a) => a.id == value);
                  onSelectAddress(picked);
                }
              },
            ),
          ),
        ),
        if (selectedAddress != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: brand.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brand.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedAddress.summary.trim().isNotEmpty &&
                          selectedAddress.summary.trim() !=
                              selectedAddress.displayName)
                        Text(
                          selectedAddress.summary.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        )
                      else
                        Text(
                          (selectedAddress.deliveryZone?.trim().isNotEmpty ??
                                  false)
                              ? selectedAddress.deliveryZone!.trim()
                              : l10n.checkoutDeliveryAddressSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      if (!selectedAddress.isDeliverable) ...[
                        const SizedBox(height: 4),
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
          ),
        ],
        if (checkoutState.hasAddressError) ...[
          const SizedBox(height: 10),
          CheckoutNotice(
            icon: Icons.cloud_off_outlined,
            message: (checkoutState.addressError?.trim().isNotEmpty ?? false)
                ? checkoutState.addressError!.trim()
                : l10n.checkoutAddressError,
            color: colors.error,
            action: TextButton(
              onPressed: onRetryAddresses,
              style: TextButton.styleFrom(
                foregroundColor: brand,
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
