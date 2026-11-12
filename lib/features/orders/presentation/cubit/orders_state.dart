import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';

/// Which slice of the order history is shown.
///
/// The backend expects `status=current` for still-open orders and
/// `status=past` for completed or cancelled ones.
enum OrdersFilter { current, past }

extension OrdersFilterApi on OrdersFilter {
  String get apiValue => name;

  bool get isCurrent => this == OrdersFilter.current;
}

enum OrdersStatus { initial, loading, success, failure }

/// Paginated order history shown in the orders tab.
class OrdersState {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.filter = OrdersFilter.current,
    this.orders = const [],
    this.errorMessage,
    this.currentPage = 0,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final OrdersStatus status;
  final OrdersFilter filter;

  /// Kept while a refresh runs so the visible list never blanks.
  final List<Order> orders;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  /// Last page that was merged into [orders].
  final int currentPage;

  /// Last page the backend reports.
  final int lastPage;

  /// Total number of orders across every page.
  final int total;

  /// Whether the next page request is in flight.
  final bool isLoadingMore;

  /// Message returned when the next page could not be loaded.
  final String? loadMoreError;

  bool get isLoading => status == OrdersStatus.loading;

  bool get isInitialLoading => isLoading && orders.isEmpty;

  bool get isRefreshing => isLoading && orders.isNotEmpty;

  bool get hasOrders => orders.isNotEmpty;

  bool get hasError => status == OrdersStatus.failure && orders.isEmpty;

  bool get hasMore => currentPage > 0 && currentPage < lastPage;

  bool get hasLoadMoreError => loadMoreError != null;

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersFilter? filter,
    List<Order>? orders,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      orders: orders ?? this.orders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
    );
  }
}
