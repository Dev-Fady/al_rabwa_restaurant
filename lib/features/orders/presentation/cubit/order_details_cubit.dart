import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'order_details_state.dart';
import 'orders_state.dart';

/// Loads one order from `GET /api/orders/{orderId}`.
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repository, this.orderId, {String lang = 'ar'})
    : super(OrderDetailsState(lang: lang));

  final OrdersRepository _repository;
  final int orderId;

  /// Fetches the order, optionally for a new language.
  Future<void> load({String? lang}) async {
    final targetLang = lang ?? state.lang;
    if (state.isLoading && (lang == null || lang == state.lang)) return;

    emit(
      state.copyWith(
        status: OrdersStatus.loading,
        lang: targetLang,
        clearError: true,
      ),
    );

    final result = await _repository.fetchOrderDetails(
      orderId: orderId,
      lang: targetLang,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (order) => emit(
        OrderDetailsState(
          status: OrdersStatus.success,
          order: order,
          lang: targetLang,
        ),
      ),
    );
  }

  Future<void> retry() => load();
}
