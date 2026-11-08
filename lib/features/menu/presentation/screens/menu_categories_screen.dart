import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_categories_grid.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_categories_hero.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_header.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_item_cards.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Every menu section as a card grid, opened from "عرض الكل" under the home
/// page's "اكتشف المنيو" carousel.
class MenuCategoriesScreen extends StatefulWidget {
  const MenuCategoriesScreen({super.key});

  @override
  State<MenuCategoriesScreen> createState() => _MenuCategoriesScreenState();
}

class _MenuCategoriesScreenState extends State<MenuCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // The home section normally loads the categories; deep links may land
    // here first, so start the request only when nothing was loaded yet.
    final cubit = context.read<HomeCategoriesCubit>();
    if (cubit.state.status == HomeCategoriesStatus.initial) {
      cubit.load();
    }
  }

  void _backHome() => context.go(AppRoutes.home);

  void _openCategory(MenuCategory category) {
    final menuCubit = context.read<MenuCubit>();
    context.go(AppRoutes.menu);
    menuCubit.openCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<StoreConfigCubit, StoreConfigState>(
          builder: (context, storeState) {
            final restaurant =
                storeState.settings?.restaurant ?? const RestaurantBrand();
            final restaurantName = restaurant.name.trim().isNotEmpty
                ? restaurant.name
                : l10n.appTitle;

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 600
                    ? 32.0
                    : 16.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8,
                        horizontalPadding,
                        32,
                      ),
                      children: [
                        MenuHeader(
                          restaurant: restaurant,
                          restaurantName: restaurantName,
                          title: l10n.menuCategoriesTitle,
                          subtitle: l10n.menuCategoriesSubtitle,
                        ),
                        const SizedBox(height: 12),
                        _BackHomePill(
                          label: l10n.menuCategoriesBackHome,
                          onTap: _backHome,
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<HomeCategoriesCubit, HomeCategoriesState>(
                          builder: (context, state) {
                            final categories = state.categories;

                            if (categories.isEmpty) {
                              if (state.status ==
                                  HomeCategoriesStatus.failure) {
                                return MenuErrorState(
                                  message: l10n.homeCategoriesError,
                                  onRetry: () => context
                                      .read<HomeCategoriesCubit>()
                                      .load(refresh: true),
                                );
                              }
                              if (state.status ==
                                  HomeCategoriesStatus.success) {
                                return MenuEmptyState(
                                  message: l10n.menuCategoriesEmpty,
                                );
                              }
                              return const MenuCategoriesGridSkeleton();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MenuCategoriesHero(
                                  title: l10n.menuCategoriesHeroTitle,
                                  subtitle: l10n.menuCategoriesHeroSubtitle(
                                    restaurantName,
                                    categories.length,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MenuCategoriesGrid(
                                  categories: categories,
                                  itemsLabel: (category) =>
                                      l10n.menuItemsCount(category.itemsCount),
                                  onCategoryTap: _openCategory,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Soft green pill that returns to the home page.
class _BackHomePill extends StatelessWidget {
  const _BackHomePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: Color.alphaBlend(
            brandColor.withValues(alpha: 0.09),
            colors.surface,
          ),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isRtl ? Icons.chevron_right : Icons.chevron_left,
                    size: 20,
                    color: brandColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: brandColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
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
