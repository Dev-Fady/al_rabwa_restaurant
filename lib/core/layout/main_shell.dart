
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wady_elmalekat/core/layout/widgets/shell_navigation_rail.dart';
import 'package:wady_elmalekat/core/widget/app_bottom_nav_bar.dart';
import 'package:wady_elmalekat/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:wady_elmalekat/features/cart/presentation/cubit/cart_state.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Below this width the original phone layout is used unchanged.
  static const double _phoneMaxWidth = 600;

  /// At/above this width the rail shows full text labels + logo header.
  static const double _extendedRailMinWidth = 1100;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _phoneMaxWidth) {
          return _PhoneShell(navigationShell: navigationShell);
        }
        return _WideShell(
          navigationShell: navigationShell,
          extended: constraints.maxWidth >= _extendedRailMinWidth,
          onDestinationSelected: _goBranch,
        );
      },
    );
  }
}

/// Phone layout — unchanged from the original implementation.
class _PhoneShell extends StatelessWidget {
  const _PhoneShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      // Live cart badge (`GET /api/cart` through the shell-level cubit).
      bottomNavigationBar: BlocSelector<CartCubit, CartState, int>(
        selector: (state) => state.badgeCount,
        builder: (context, cartBadgeCount) => AppBottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          cartBadgeCount: cartBadgeCount,
        ),
      ),
    );
  }
}

/// Laptop/desktop layout — side rail + content.
/// The rail is the first [Row] child so it sits on the trailing side
/// in RTL locales, matching the phone bar's visual order.
class _WideShell extends StatelessWidget {
  const _WideShell({
    required this.navigationShell,
    required this.extended,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final bool extended;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            ShellNavigationRail(
              currentIndex: navigationShell.currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: extended,
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppBottomNavBar.borderColor,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
