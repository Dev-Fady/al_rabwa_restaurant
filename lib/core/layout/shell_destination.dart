import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Single bottom-nav / rail destination.
///
/// Holds [IconData], so it lives with the shell layout rather than in the
/// domain layer.
///
/// Order MUST match the router branches in `AppRouter`:
/// 0 home, 1 menu, 2 cart, 3 orders, 4 store.
@immutable
class ShellDestination {
  const ShellDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Single source of truth for the five app tabs.
///
/// Used by `AppBottomNavBar`, `ShellNavigationRail`, and documented in
/// `AppRouter` branch order. Labels follow the app locale, so this is a
/// function — not a const list — resolved per build.
List<ShellDestination> shellDestinations(AppLocalizations l10n) {
  return [
    ShellDestination(label: l10n.navHome, icon: Icons.home_outlined),
    ShellDestination(label: l10n.navMenu, icon: Icons.restaurant_outlined),
    ShellDestination(label: l10n.navCart, icon: Icons.shopping_bag_outlined),
    ShellDestination(label: l10n.navOrders, icon: Icons.receipt_long_outlined),
    ShellDestination(label: l10n.navStore, icon: Icons.storefront_outlined),
  ];
}
