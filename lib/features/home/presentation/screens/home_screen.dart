import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_delivery_address_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_categories_section.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_delivery_location_bar.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_header.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_loading_shimmer.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_order_type_selector.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_search_bar.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_status_body.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreConfigCubit, StoreConfigState>(
      builder: (context, state) {
        final settings = state.settings;

        return Scaffold(
          body: SafeArea(
            child: settings == null
                ? state.status == StoreConfigStatus.failure
                      ? HomeStatusBody(
                          state: state,
                          onRetry: () => context.read<StoreConfigCubit>().load(
                            refresh: true,
                          ),
                        )
                      : const HomeLoadingShimmer()
                : _HomeContent(settings: settings),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({required this.settings});

  final RestaurantSettings settings;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    _syncOrderType();
  }

  @override
  void didUpdateWidget(covariant _HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOrderType();
  }

  /// Keeps the cart's order type valid when the settings load or change.
  void _syncOrderType() {
    final orderTypes = widget.settings.ordering.orderTypes;
    if (orderTypes.isEmpty) return;

    final cartCubit = context.read<CartCubit>();
    if (!orderTypes.any((type) => type.value == cartCubit.state.orderType)) {
      cartCubit.setOrderType(orderTypes.first.value);
    }
  }

  /// Opens the saved-address picker and shows the chosen address in the bar.
  ///
  /// The list is reloaded afterwards so a registration that just happened, or
  /// a default/delete change made inside the picker, is reflected even when
  /// the customer comes back without picking anything.
  Future<void> _selectDeliveryAddress(BuildContext context) async {
    final cubit = context.read<HomeDeliveryAddressCubit>();
    final authed = await AuthHelper.ensureAuthenticated(context);
    if (!authed || !context.mounted) return;

    final address = await context.push<Address>(
      AppRoutes.selectAddress,
      extra: cubit.state.selectedAddress?.id,
    );
    if (!context.mounted) return;

    if (address != null) {
      cubit.select(address);
      await cubit.load(force: true);
    } else {
      // Back from the picker without choosing: re-resolve to the saved default
      // so a default changed there is reflected on the home bar.
      await cubit.load(preferDefault: true, force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<StoreConfigCubit>();
    final settings = widget.settings;
    final banners = settings.home.banners;
    final backgroundImage = settings.theme.backgroundImage.trim();

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImage.isNotEmpty)
            _HomeBackgroundImage(url: backgroundImage),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    // ignore: deprecated_member_use
                    cacheExtent: 2500,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      32,
                    ),
                    children: [
                      // 1. Header with title, language toggle, and logo
                      HomeHeader(settings: settings),
                      const SizedBox(height: 14),

                      // 2. Delivery location selection bar
                      BlocSelector<
                        HomeDeliveryAddressCubit,
                        HomeDeliveryAddressState,
                        Address?
                      >(
                        selector: (state) => state.selectedAddress,
                        builder: (context, address) => HomeDeliveryLocationBar(
                          selectedAddress: address?.displayName,
                          onTap: () => _selectDeliveryAddress(context),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Order type toggle (Delivery / Takeaway / ...)
                      if (settings.ordering.orderTypes.isNotEmpty) ...[
                        BlocSelector<CartCubit, Cart, String>(
                          selector: (cart) => cart.orderType,
                          builder: (context, selectedType) {
                            final orderTypes = settings.ordering.orderTypes;
                            final effectiveType =
                                orderTypes.any(
                                  (type) => type.value == selectedType,
                                )
                                ? selectedType
                                : orderTypes.first.value;

                            return HomeOrderTypeSelector(
                              options: orderTypes,
                              selectedType: effectiveType,
                              onChanged: (type) =>
                                  context.read<CartCubit>().setOrderType(type),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 4. Search bar ("ماذا تشتهي اليوم؟")
                      HomeSearchBar(onTap: () => context.go(AppRoutes.menu)),
                      const SizedBox(height: 18),

                      // 5. Promotional hero banners (swipeable, with dots).
                      if (settings.home.showBanner) ...[
                        HomeBannerCarousel(
                          banners: banners,
                          restaurant: settings.restaurant,
                          onBannerTap: (banner) => _openBanner(context, banner),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // 6. Menu categories carousel
                      const SizedBox(height: 24),
                      HomeCategoriesSection(
                        onViewAll: () => context.go(AppRoutes.menuCategories),
                        onCategoryTap: (category) {
                          final menuCubit = context.read<MenuCubit>();
                          context.go(AppRoutes.menu);
                          menuCubit.openCategory(category);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeBackgroundImage extends StatelessWidget {
  const _HomeBackgroundImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.12,
        child: AppNetworkImage(
          url: url,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

/// Follows a banner's `link_type`: its section, its dish, an external link, or
/// the menu when the banner carries no target.
void _openBanner(BuildContext context, HomeBanner banner) {
  if (banner.opensExternalUrl) {
    final uri = Uri.tryParse(banner.url.trim());
    if (uri != null) {
      _launchExternal(uri);
      return;
    }
  }

  final categoryId = banner.categoryId;
  if (banner.linkType == 'category' && categoryId != null) {
    final menuCubit = context.read<MenuCubit>();
    context.go(AppRoutes.menu);
    menuCubit.openCategoryById(categoryId);
    return;
  }

  final itemId = banner.itemId;
  if (banner.linkType == 'item' && itemId != null) {
    context.go(AppRoutes.menuItemPath(itemId));
    return;
  }

  context.go(AppRoutes.menu);
}

Future<void> _launchExternal(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}
