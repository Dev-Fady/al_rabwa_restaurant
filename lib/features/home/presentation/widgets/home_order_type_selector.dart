import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:flutter/material.dart';

/// Order type selector tabs matching the design:
/// Prominent rounded buttons for delivery ("توصيل"), takeaway ("استلام من المطعم"),
/// and dine-in ("داخل المطعم").
///
/// Preserves full labels without truncation across all screen sizes.
class HomeOrderTypeSelector extends StatelessWidget {
  const HomeOrderTypeSelector({
    super.key,
    required this.options,
    required this.selectedType,
    required this.onChanged,
  });

  final List<OrderOption> options;
  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    // When 2 options (delivery & takeaway), expand evenly across the available width
    if (options.length <= 2) {
      return Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _OrderTypeButton(
                option: options[i],
                isSelected: options[i].value == selectedType,
                onTap: () => onChanged(options[i].value),
              ),
            ),
          ],
        ],
      );
    }

    // When 3+ options: horizontal scrollable row ensures all labels are 100% visible
    // and never truncated with ellipsis on any device width.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _OrderTypeButton(
              option: options[i],
              isSelected: options[i].value == selectedType,
              onTap: () => onChanged(options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  const _OrderTypeButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final OrderOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brandColor = context.appColors.brandGreen;

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: Material(
        color: isSelected ? brandColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? brandColor : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: brandColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  softWrap: false,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                _OrderOptionIcon(
                  optionValue: option.value,
                  isSelected: isSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderOptionIcon extends StatelessWidget {
  const _OrderOptionIcon({
    required this.optionValue,
    required this.isSelected,
  });

  final String optionValue;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (optionValue == 'delivery') {
      return const _DeliveryScooterBadge();
    }

    if (optionValue == 'takeaway') {
      return Icon(
        Icons.storefront_outlined,
        size: 21,
        color: isSelected ? Colors.white : const Color(0xFF1F2937),
      );
    }

    if (optionValue == 'dine_in') {
      return Icon(
        Icons.restaurant_outlined,
        size: 20,
        color: isSelected ? Colors.white : const Color(0xFF1F2937),
      );
    }

    return Icon(
      Icons.shopping_bag_outlined,
      size: 20,
      color: isSelected ? Colors.white : const Color(0xFF1F2937),
    );
  }
}

/// Delivery scooter icon styled to match the teal & red scooter from the design.
class _DeliveryScooterBadge extends StatelessWidget {
  const _DeliveryScooterBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(
            Icons.delivery_dining,
            size: 24,
            color: Color(0xFF00C4D6),
          ),
          Positioned(
            top: 1,
            right: 4,
            child: Icon(
              Icons.circle,
              size: 5.5,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}
