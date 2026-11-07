import 'package:al_rabwa_restaurant/core/layout/shell_destination.dart';
import 'package:al_rabwa_restaurant/core/widget/app_bottom_nav_bar.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Side navigation rail for laptop/desktop shells.
///
/// Mirrors the phone [AppBottomNavBar]: same five destinations, labels
/// and icons — only the presentation differs.
///
/// Order MUST match the router branches and the bottom bar tabs:
/// 0 home, 1 menu, 2 cart, 3 orders, 4 store.
class ShellNavigationRail extends StatelessWidget {
  const ShellNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.extended,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  // Single source of truth — same order as AppBottomNavBar + router branches.

  @override
  Widget build(BuildContext context) {
    final destinations = shellDestinations(AppLocalizations.of(context)!);
    final scheme = Theme.of(context).colorScheme;
    return NavigationRail(
      extended: extended,
      minWidth: 76,
      minExtendedWidth: 220,
      backgroundColor: scheme.surface,
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      useIndicator: true,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.primary),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        color: scheme.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 13,
      ),
      labelType: extended ? null : NavigationRailLabelType.all,
      destinations: [
        for (final destination in destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            label: Text(destination.label, softWrap: false),
          ),
      ],
    );
  }
}
