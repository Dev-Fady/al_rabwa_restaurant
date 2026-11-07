import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/cubit/menu_state.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_categories_sheet.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_category_hero.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_category_tabs.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_header.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_item_cards.dart';
import 'package:al_rabwa_restaurant/features/menu/presentation/widgets/menu_search_bar.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Menu tab: categories on top, then the selected category's dishes rendered
/// according to its `display_style` (`large`, `list` or `grid`).
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Load lazily when the tab is opened, not at app start.
    context.read<MenuCubit>().loadIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    if (query == _query) return;
    setState(() => _query = query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _openItem(MenuItem item) {
    final id = item.id;
    if (id == null) return;
    context.push(AppRoutes.menuItemPath(id));
  }

  List<MenuItem> _visibleItems(List<MenuItem> items) {
    if (_query.isEmpty) return items;
    final needle = _query.toLowerCase();
    return items
        .where((item) => item.name.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  String _firstItemImage(List<MenuItem> items) {
    for (final item in items) {
      if (item.hasImage) return item.image;
    }
    return '';
  }

  Future<void> _openCategoriesSheet(BuildContext context, MenuState state) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.6,
        ),
        child: MenuCategoriesSheet(
          categories: state.categories,
          selectedId: state.selectedCategory?.id,
          onSelected: (category) {
            Navigator.of(sheetContext).pop();
            context.read<MenuCubit>().selectCategory(category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<StoreConfigCubit, StoreConfigState>(
          builder: (context, storeState) {
            final settings = storeState.settings;
            final restaurant = settings?.restaurant ?? const RestaurantBrand();
            final currency = settings?.currency ?? const StoreCurrency();
            final restaurantName = restaurant.name.trim().isNotEmpty
                ? restaurant.name
                : l10n.appTitle;

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 600
                    ? 32.0
                    : 16.0;
                final gridColumns = constraints.maxWidth >= 1000
                    ? 4
                    : (constraints.maxWidth >= 700 ? 3 : 2);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: BlocBuilder<MenuCubit, MenuState>(
                      builder: (context, state) {
                        final selectedCategory = state.selectedCategory;
                        final items = _visibleItems(state.items);
                        final emptyMessage = _query.isNotEmpty
                            ? l10n.menuSearchNoResults
                            : l10n.menuEmptyCategory;
                        final showCategoryIntro =
                            _query.isEmpty && selectedCategory != null;

                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                8,
                                horizontalPadding,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: MenuHeader(
                                  restaurant: restaurant,
                                  restaurantName: restaurantName,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16,
                                horizontalPadding,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: MenuSearchBar(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  onClear: _clearSearch,
                                ),
                              ),
                            ),
                            if (state.hasCategories)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: MenuCategoryTabs(
                                    categories: state.categories,
                                    selectedCategoryId: selectedCategory?.id,
                                    onSelected: (category) => context
                                        .read<MenuCubit>()
                                        .selectCategory(category),
                                    horizontalPadding: horizontalPadding,
                                  ),
                                ),
                              ),
                            if (state.categoriesStatus == MenuStatus.failure &&
                                !state.hasCategories)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  24,
                                  horizontalPadding,
                                  24,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: MenuErrorState(
                                    message: l10n.homeCategoriesError,
                                    onRetry: () => context
                                        .read<MenuCubit>()
                                        .load(refresh: true),
                                  ),
                                ),
                              )
                            else if (state.categoriesStatus ==
                                    MenuStatus.loading &&
                                !state.hasCategories)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  20,
                                  horizontalPadding,
                                  28,
                                ),
                                sliver: const SliverToBoxAdapter(
                                  child: MenuItemsSkeleton(),
                                ),
                              )
                            else if (selectedCategory != null) ...[
                              if (showCategoryIntro) ...[
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalPadding,
                                    16,
                                    horizontalPadding,
                                    0,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: MenuCategoryHero(
                                      category: selectedCategory,
                                      fallbackImage: _firstItemImage(
                                        state.items,
                                      ),
                                      itemsCount:
                                          selectedCategory.itemsCount > 0
                                          ? selectedCategory.itemsCount
                                          : state.items.length,
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalPadding,
                                    8,
                                    horizontalPadding,
                                    0,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _MenuBrowseAll(
                                      onBrowseAll: () =>
                                          _openCategoriesSheet(context, state),
                                      hint: l10n.menuChooseDishHint,
                                    ),
                                  ),
                                ),
                              ],
                              SliverMenuItems(
                                status: state.itemsStatus,
                                items: items,
                                displayStyle: selectedCategory.displayStyle,
                                currency: currency,
                                emptyMessage: emptyMessage,
                                onRetry: () =>
                                    context.read<MenuCubit>().retryItems(),
                                horizontalPadding: horizontalPadding,
                                gridColumns: gridColumns,
                                onItemTap: _openItem,
                              ),
                            ],
                          ],
                        );
                      },
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

class _MenuBrowseAll extends StatelessWidget {
  const _MenuBrowseAll({required this.onBrowseAll, required this.hint});

  final VoidCallback onBrowseAll;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onBrowseAll,
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.brandGreen,
              minimumSize: const Size(48, 44),
              padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 2,
              children: [
                Text(
                  AppLocalizations.of(context)!.menuBrowseAllCategories,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.3,
                  ),
                ),
                Icon(
                  isRtl ? Icons.chevron_left : Icons.chevron_right,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        Text(
          hint,
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
