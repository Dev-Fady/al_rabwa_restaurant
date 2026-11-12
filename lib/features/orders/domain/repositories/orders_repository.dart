import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:dartz/dartz.dart' hide Order;

/// Creates an order from the current cart.
abstract class OrdersRepository {
  Future<Either<Failure, Order>> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  });
}
