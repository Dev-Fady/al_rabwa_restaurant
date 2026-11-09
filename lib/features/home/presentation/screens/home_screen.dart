import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_categories_section.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_delivery_location_bar.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_header.dart';
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
                ? HomeStatusBody(
                    state: state,
                    onRetry: () =>
                        context.read<StoreConfigCubit>().load(refresh: true),
                  )
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
  late String _selectedOrderType;

  /// Last address saved from the add-address screen in this session.
  Address? _deliveryAddress;

  @override
  void initState() {
    super.initState();
    final orderTypes = widget.settings.ordering.orderTypes;
    _selectedOrderType = orderTypes.isNotEmpty
        ? orderTypes.first.value
        : 'delivery';
  }

  @override
  void didUpdateWidget(covariant _HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final orderTypes = widget.settings.ordering.orderTypes;
    if (orderTypes.isNotEmpty &&
        !orderTypes.any((t) => t.value == _selectedOrderType)) {
      _selectedOrderType = orderTypes.first.value;
    }
  }

  /// Opens the add-address form and shows the saved address in the bar.
  Future<void> _openAddAddress(BuildContext context) async {
    final authed = await AuthHelper.ensureAuthenticated(context);
    if (!authed || !mounted) return;

    final address = await context.push<Address>(AppRoutes.addAddress);
    if (!mounted || address == null) return;
    setState(() => _deliveryAddress = address);
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
                      HomeDeliveryLocationBar(
                        selectedAddress: _deliveryAddress?.displayName,
                        onTap: () => _openAddAddress(context),
                      ),
                      const SizedBox(height: 12),

                      // 3. Order type toggle (Delivery / Takeaway / ...)
                      if (settings.ordering.orderTypes.isNotEmpty) ...[
                        HomeOrderTypeSelector(
                          options: settings.ordering.orderTypes,
                          selectedType: _selectedOrderType,
                          onChanged: (type) {
                            setState(() {
                              _selectedOrderType = type;
                            });
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
