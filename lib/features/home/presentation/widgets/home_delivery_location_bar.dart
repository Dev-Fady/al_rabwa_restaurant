import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Delivery location selection bar matching the design:
/// [Dropdown arrow] ... [Deliver to: Select your location] [Red Pin Icon]
class HomeDeliveryLocationBar extends StatelessWidget {
  const HomeDeliveryLocationBar({
    super.key,
    this.selectedAddress,
    this.onTap,
  });

  final String? selectedAddress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final brandColor = context.appColors.brandGreen;

    final locationText = (selectedAddress != null && selectedAddress!.trim().isNotEmpty)
        ? selectedAddress!
        : l10n.selectLocation;

    return Semantics(
      button: true,
      label: '${l10n.deliverTo} $locationText',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  color: brandColor,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.deliverTo} ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: locationText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: brandColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _CustomLocationPin(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomLocationPin extends StatelessWidget {
  const _CustomLocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 26,
            color: Colors.black87,
          ),
          const Positioned(
            top: 2,
            child: Icon(
              Icons.location_on,
              size: 22,
              color: Color(0xFFDC2626),
            ),
          ),
          Positioned(
            top: 7,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
