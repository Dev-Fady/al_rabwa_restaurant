import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/layout/main_shell.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/add_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/cubit/address_list_cubit.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/add_address_screen.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/address_details_screen.dart';
import 'package:al_rabwa_restaurant/features/addresses/presentation/screens/address_selection_screen.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/screens/home_screen.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/item_details_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/item_details_screen.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/menu_categories_screen.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/screens/menu_screen.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_cubit.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/screens/device_registration_screen.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/shell/presentation/screens/section_placeholder_screen.dart';
import 'package:al_rabwa_restaurant/features/splash/presentation/screens/splash_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        path: AppRoutes.registration,
        builder: (context, state) => BlocProvider<DeviceRegistrationCubit>(
          create: (_) => getIt<DeviceRegistrationCubit>(),
          child: DeviceRegistrationScreen(
            onLocaleChanged: (code) {
              try {
                context.read<SettingsCubit>().changeLanguage(code);
              } catch (_) {
                // Isolated tests may not provide the app-level settings cubit.
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => SectionPlaceholderScreen(
          title: AppLocalizations.of(context)!.loginTitle,
          icon: Icons.login,
        ),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        builder: (context, state) {
          // Read the locale here: the provider's `create` runs during mount
          // and must not subscribe to inherited widgets.
          final lang = Localizations.localeOf(context).languageCode;
          final existing = state.extra is Address
              ? state.extra as Address
              : null;

          return BlocProvider<AddAddressCubit>(
            create: (_) => getIt<AddAddressCubit>(param1: lang),
            child: AddAddressScreen(existingAddress: existing),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.selectAddress,
        builder: (context, state) {
          final lang = Localizations.localeOf(context).languageCode;
          final selectedId = state.extra is int ? state.extra as int : null;

          return BlocProvider<AddressListCubit>(
            create: (_) => getIt<AddressListCubit>(param1: lang)..load(),
            child: AddressSelectionScreen(selectedAddressId: selectedId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addressDetails,
        builder: (context, state) {
          final addressId = int.tryParse(state.pathParameters['id'] ?? '');
          if (addressId == null) {
            return SectionPlaceholderScreen(
              title: AppLocalizations.of(context)!.pageNotFound,
              icon: Icons.error_outline,
            );
          }

          final lang = Localizations.localeOf(context).languageCode;

          return BlocProvider<AddressDetailsCubit>(
            create: (_) =>
                getIt<AddressDetailsCubit>(param1: addressId, param2: lang)
                  ..load(),
            child: const AddressDetailsScreen(),
          );
        },
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
                routes: [
                  GoRoute(
                    path: AppRoutes.menuCategoriesSegment,
                    builder: (context, state) => const MenuCategoriesScreen(),
                  ),
                  GoRoute(
                    path: AppRoutes.menuItemSegment,
                    builder: (context, state) {
                      final itemId = int.tryParse(
                        state.pathParameters['itemId'] ?? '',
                      );
                      if (itemId == null) {
                        return SectionPlaceholderScreen(
                          title: AppLocalizations.of(context)!.pageNotFound,
                          icon: Icons.error_outline,
                        );
                      }

                      // Read the locale here: the provider's `create` runs
                      // during mount and must not subscribe to inherited widgets.
                      final lang = Localizations.localeOf(context).languageCode;

                      return BlocProvider<ItemDetailsCubit>(
                        create: (_) => getIt<ItemDetailsCubit>(
                          param1: itemId,
                          param2: lang,
                        )..load(),
                        child: const ItemDetailsScreen(),
                      );
                    },
                  ),
                ],
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
