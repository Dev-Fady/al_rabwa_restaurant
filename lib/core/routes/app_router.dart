import 'package:al_rabwa_restaurant/core/layout/main_shell.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/screens/home_screen.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/menu_screen.dart';
import 'package:al_rabwa_restaurant/features/shell/presentation/screens/section_placeholder_screen.dart';
import 'package:al_rabwa_restaurant/features/splash/presentation/screens/splash_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    // Cold start always lands on the splash; the splash then opens home.
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => SectionPlaceholderScreen(
          title: AppLocalizations.of(context)!.loginTitle,
          icon: Icons.login,
        ),
      ),
      // Branch order MUST match `shellDestinations` and `AppBottomNavBar`.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.menu,
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => SectionPlaceholderScreen(
                  title: AppLocalizations.of(context)!.navCart,
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => SectionPlaceholderScreen(
                  title: AppLocalizations.of(context)!.navOrders,
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.store,
                builder: (context, state) => SectionPlaceholderScreen(
                  title: AppLocalizations.of(context)!.navStore,
                  icon: Icons.storefront_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '${l10n.pageNotFound}\n${state.uri}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    },
  );
}
