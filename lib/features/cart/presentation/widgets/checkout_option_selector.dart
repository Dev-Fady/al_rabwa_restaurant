import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// One value/label pair rendered in the checkout option selectors.
class CheckoutChoice {
  const CheckoutChoice({
    required this.value,
    required this.label,
    this.icon,
    this.emoji,
  });

  final String value;
  final String label;
  final IconData? icon;
  final String? emoji;
}

/// Horizontally scrollable segmented pill tab selector matching the restaurant UI.
/// Preserves full labels without truncation across all screen sizes.
class CheckoutOptionSelector extends StatelessWidget {
  const CheckoutOptionSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<CheckoutChoice> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark
        ? colors.surfaceContainerHighest
        : const Color(0xFFF3F4EF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = (options.length - 1) * 6.0;
        final availableWidth = constraints.maxWidth - 10.0 - totalSpacing;
        final tabMinWidth = availableWidth > 0
            ? (availableWidth / options.length).floorToDouble()
            : 0.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    _OptionTab(
                      option: options[i],
                      isSelected: options[i].value == selectedValue,
                      onTap: () => onChanged(options[i].value),
                      brandColor: brand,
                      textColor: colors.onSurface,
                      minWidth: tabMinWidth,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionTab extends StatelessWidget {
  const _OptionTab({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.brandColor,
    required this.textColor,
    this.minWidth,
  });

  final CheckoutChoice option;
  final bool isSelected;
  final VoidCallback onTap;
  final Color brandColor;
  final Color textColor;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final activeTextColor = isSelected ? Colors.white : textColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
              minHeight: 48,
              minWidth: minWidth ?? 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? brandColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: brandColor.withValues(alpha: 0.22),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  softWrap: false,
                  style: TextStyle(
                    color: activeTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (option.emoji != null && option.emoji!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    option.emoji!,
                    style: const TextStyle(fontSize: 16, height: 1.1),
                  ),
                ] else if (option.icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    option.icon,
                    size: 17,
                    color: activeTextColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
