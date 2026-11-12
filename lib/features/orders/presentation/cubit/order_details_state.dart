import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';

import 'orders_state.dart';

/// One order opened from the history list.
class OrderDetailsState {
  const OrderDetailsState({
    this.status = OrdersStatus.initial,
    this.order,
    this.errorMessage,
    this.lang = 'ar',
  });

  final OrdersStatus status;
  final Order? order;

  /// Message returned by the API; empty means "show the localized fallback".
  final String? errorMessage;

  /// BCP-47 language the order was loaded in.
  final String lang;

  bool get isLoading => status == OrdersStatus.loading;

  bool get hasOrder => order != null;

  bool get hasError => status == OrdersStatus.failure;

  OrderDetailsState copyWith({
    OrdersStatus? status,
    Order? order,
    String? errorMessage,
    String? lang,
    bool clearError = false,
  }) {
    return OrderDetailsState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lang: lang ?? this.lang,
    );
  }
}
