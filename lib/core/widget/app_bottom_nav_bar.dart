import 'package:al_rabwa_restaurant/core/layout/shell_destination.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Bottom navigation bar matching the restaurant reference design.
///
/// Five tabs laid out following the ambient [Directionality] (in Arabic the
/// home tab is the right-most one). The selected tab gets a soft green pill
/// around its icon only.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartBadgeCount;

  /// Index of the cart tab in [shellDestinations], used for the live badge.
  static const int cartIndex = 2;

  // ── Sizing ──
  static const double _iconSize = 26;
  static const double _labelSize = 12;
  static const double _pillRadius = 28;

  @override
  Widget build(BuildContext context) {
    final destinations = shellDestinations(AppLocalizations.of(context)!);
    final safeIndex = currentIndex.clamp(0, destinations.length - 1);
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < destinations.length; i++)
                _NavItem(
                  label: destinations[i].label,
                  icon: destinations[i].icon,
                  selected: safeIndex == i,
                  badgeCount: i == cartIndex ? cartBadgeCount : null,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBottomNavBar._pillRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Center(
              heightFactor: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected background around the icon only.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppBottomNavBar._pillRadius,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          size: AppBottomNavBar._iconSize,
                          color: color,
                        ),
                        if (badgeCount != null && badgeCount! > 0)
                          PositionedDirectional(
                            top: -5,
                            end: -9,
                            child: _Badge(count: badgeCount!),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Label outside the selected background.
                  Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppBottomNavBar._labelSize,
                      height: 1.15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: color,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 10,
            height: 1,
            fontWeight: FontWeight.w700,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
