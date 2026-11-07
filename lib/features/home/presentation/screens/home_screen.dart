import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_categories_section.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_delivery_location_bar.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_header.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_order_type_selector.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_search_bar.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_status_body.dart';
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
                        onTap: () {
                          // Handled by location picker feature
                        },
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

                      // 5. Promotional Hero Banners
                      if (settings.home.showBanner) ...[
                        if (banners.isEmpty)
                          HomeHeroBanner(
                            banner: null,
                            restaurant: settings.restaurant,
                            onTap: () => context.go(AppRoutes.menu),
                          )
                        else
                          for (var i = 0; i < banners.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            HomeHeroBanner(
                              banner: banners[i],
                              restaurant: settings.restaurant,
                              onTap: () => _openBanner(context, banners[i]),
                            ),
                          ],
                        const SizedBox(height: 18),
                      ],

                      // 6. Menu categories carousel
                      const SizedBox(height: 24),
                      HomeCategoriesSection(
                        onViewAll: () => context.go(AppRoutes.menu),
                        onCategoryTap: (_) => context.go(AppRoutes.menu),
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

void _openBanner(BuildContext context, HomeBanner banner) {
  if (banner.opensExternalUrl) {
    final uri = Uri.tryParse(banner.url.trim());
    if (uri != null) {
      _launchExternal(uri);
      return;
    }
  }
  context.go(AppRoutes.menu);
}

Future<void> _launchExternal(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}
