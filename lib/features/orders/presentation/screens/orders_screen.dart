import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/cubit/orders_state.dart';
import 'package:al_rabwa_restaurant/features/orders/presentation/widgets/order_card.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Orders tab: the customer's current and past orders, paginated by the API.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// Distance from the bottom that triggers the next page request.
  static const double _loadMoreThreshold = 320;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;

    final position = _controller.position;
    if (position.extentAfter < _loadMoreThreshold) {
      context.read<OrdersCubit>().loadMore();
    }
  }

  /// Loads the next page when a short page does not fill the viewport, so the
  /// user is never stuck with an empty scroll area above a "more" footer.
  void _scheduleViewportFill(OrdersState state) {
    if (state.status != OrdersStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;

      final position = _controller.position;
      if (position.extentAfter < _loadMoreThreshold) {
        context.read<OrdersCubit>().loadMore();
      }
    });
  }

  void _selectFilter(OrdersState state, OrdersFilter filter) {
    if (state.filter == filter) return;

    context.read<OrdersCubit>().changeFilter(filter);
    if (_controller.hasClients) _controller.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(l10n.navOrders),
        backgroundColor: context.appColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: BlocBuilder<StoreConfigCubit, StoreConfigState>(
          builder: (context, storeState) {
            final currency =
                storeState.settings?.currency ?? const StoreCurrency();

            return BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                _scheduleViewportFill(state);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth >= 600
                        ? 32.0
                        : 16.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                12,
                                horizontalPadding,
                                8,
                              ),
                              child: _OrdersFilterBar(
                                state: state,
                                onSelected: (filter) =>
                                    _selectFilter(state, filter),
                              ),
                            ),
                            Expanded(
                              child: _OrdersContent(
                                state: state,
                                currency: currency,
                                controller: _controller,
                                horizontalPadding: horizontalPadding,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrdersFilterBar extends StatelessWidget {
  const _OrdersFilterBar({required this.state, required this.onSelected});

  final OrdersState state;
  final ValueChanged<OrdersFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          key: const ValueKey('orders-filter-current'),
          label: l10n.ordersCurrentFilter,
          selected: state.filter == OrdersFilter.current,
          brand: brand,
          colors: colors,
          onTap: () => onSelected(OrdersFilter.current),
        ),
        _FilterChip(
          key: const ValueKey('orders-filter-past'),
          label: l10n.ordersPastFilter,
          selected: state.filter == OrdersFilter.past,
          brand: brand,
          colors: colors,
          onTap: () => onSelected(OrdersFilter.past),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.brand,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color brand;
  final ColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: brand.withValues(alpha: 0.14),
      backgroundColor: colors.surface,
      side: BorderSide(
        color: selected
            ? brand.withValues(alpha: 0.55)
            : colors.outlineVariant.withValues(alpha: 0.9),
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: selected ? brand : colors.onSurfaceVariant,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent({
    required this.state,
    required this.currency,
    required this.controller,
    required this.horizontalPadding,
  });

  final OrdersState state;
  final StoreCurrency currency;
  final ScrollController controller;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == OrdersStatus.initial || state.isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.appColors.brandGreen),
      );
    }

    if (state.hasError) {
      return _OrdersErrorState(
        message: _errorMessage(l10n, state),
        onRetry: () => context.read<OrdersCubit>().load(),
      );
    }

    if (!state.hasOrders) {
      return _OrdersEmptyState(
        message: state.filter.isCurrent
            ? l10n.ordersEmptyCurrent
            : l10n.ordersEmptyPast,
        actionLabel: l10n.browseMenu,
        onBrowseMenu: () => context.go(AppRoutes.menu),
      );
    }

    final showFooter =
        state.hasMore || state.isLoadingMore || state.hasLoadMoreError;

    return RefreshIndicator(
      onRefresh: () => context.read<OrdersCubit>().refresh(),
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          4,
          horizontalPadding,
          24,
        ),
        itemCount: state.orders.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.orders.length) {
            return _PaginationFooter(
              state: state,
              onRetry: () => context.read<OrdersCubit>().loadMore(),
            );
          }

          final order = state.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OrderCard(
              key: ValueKey('order-${order.id ?? index}'),
              order: order,
              currency: currency,
              onTap: order.id == null
                  ? null
                  : () => context.push(AppRoutes.orderDetailsPath(order.id!)),
            ),
          );
        },
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, OrdersState state) {
    final raw = state.errorMessage?.trim() ?? '';
    return raw.isEmpty ? l10n.ordersError : raw;
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.onRetry});

  final OrdersState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (state.hasLoadMoreError) {
      final raw = state.loadMoreError?.trim() ?? '';
      final message = raw.isEmpty ? l10n.ordersLoadMoreError : raw;

      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.onErrorContainer,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: state.isLoadingMore
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: context.appColors.brandGreen,
                ),
              )
            : const SizedBox(height: 1),
      ),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState({
    required this.message,
    required this.actionLabel,
    required this.onBrowseMenu,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brand = context.appColors.brandGreen;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 54,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onBrowseMenu,
            style: FilledButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: colors.onPrimary,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 50, color: colors.error),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
