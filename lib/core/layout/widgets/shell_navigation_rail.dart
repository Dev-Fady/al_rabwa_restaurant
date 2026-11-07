import 'package:flutter/material.dart';
import 'package:wady_elmalekat/core/widget/app_bottom_nav_bar.dart';
import 'package:wady_elmalekat/features/shell/presentation/models/shell_destination.dart';
import 'package:wady_elmalekat/l10n/app_localizations.dart';

/// Side navigation rail for laptop/desktop shells.
///
/// Mirrors the phone [AppBottomNavBar]: same five destinations, labels
/// and icons — only the presentation differs.
///
/// Order MUST match the router branches and the bottom bar tabs:
/// 0 cart, 1 categories, 2 home, 3 favorites, 4 account.
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
    return NavigationRail(
      extended: extended,
      minWidth: 76,
      minExtendedWidth: 220,
      backgroundColor: AppBottomNavBar.backgroundColor,
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      useIndicator: true,
      indicatorColor: AppBottomNavBar.activeColor.withValues(alpha: 0.12),
      selectedIconTheme: const IconThemeData(
        color: AppBottomNavBar.activeColor,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppBottomNavBar.inactiveColor,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: AppBottomNavBar.activeColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: AppBottomNavBar.inactiveColor,
        fontSize: 13,
      ),
      labelType: extended ? null : NavigationRailLabelType.all,
      destinations: List.generate(destinations.length, (index) {
        final selected = currentIndex == index;
        final destination = destinations[index];
        return NavigationRailDestination(
          icon: Icon(selected ? destination.activeIcon : destination.icon),
          selectedIcon: Icon(destination.activeIcon),
          label: Text(destination.label, softWrap: false),
        );
      }),
    );
  }
}
