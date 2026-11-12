import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'orders_state.dart';

/// Loads the customer's order history page by page and keeps the active
/// [OrdersFilter] in sync with the backend `status` query.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repository, {this.lang = 'ar'})
    : super(const OrdersState());

  final OrdersRepository _repository;

  /// BCP-47 language sent to the API so labels and addresses match the UI.
  final String lang;

  /// Guards against a stale response overwriting a newer refresh or filter.
  int _requestId = 0;

  /// Loads the first page. [refresh] keeps the current list visible while the
  /// request runs and is used by pull-to-refresh.
  Future<void> load({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    final requestId = ++_requestId;
    emit(
      state.copyWith(
        status: OrdersStatus.loading,
        clearError: true,
        clearLoadMoreError: true,
        isLoadingMore: false,
      ),
    );

    final result = await _repository.fetchOrders(
      page: 1,
      status: state.filter.apiValue,
      lang: lang,
    );
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        OrdersState(
          status: OrdersStatus.success,
          filter: state.filter,
          orders: List.unmodifiable(page.orders),
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          total: page.total,
        ),
      ),
    );
  }

  Future<void> refresh() => load(refresh: true);

  /// Switches between current and past orders and reloads from page 1.
  Future<void> changeFilter(OrdersFilter filter) async {
    if (filter == state.filter) return;

    // Invalidate any in-flight page so it cannot merge into the new filter.
    _requestId++;
    emit(OrdersState(filter: filter));
    await load();
  }

  /// Appends the next page when the list is scrolled near the bottom.
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    emit(state.copyWith(isLoadingMore: true, clearLoadMoreError: true));

    final result = await _repository.fetchOrders(
      page: state.currentPage + 1,
      status: state.filter.apiValue,
      lang: lang,
    );
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, loadMoreError: failure.message),
      ),
      (page) {
        final existingIds = {
          for (final order in state.orders)
            if (order.id != null) order.id,
        };
        final merged = [
          ...state.orders,
          for (final order in page.orders)
            if (order.id == null || !existingIds.contains(order.id)) order,
        ];

        emit(
          state.copyWith(
            status: OrdersStatus.success,
            orders: List.unmodifiable(merged),
            currentPage: page.currentPage,
            lastPage: page.lastPage,
            total: page.total,
            isLoadingMore: false,
            clearLoadMoreError: true,
          ),
        );
      },
    );
  }
}
