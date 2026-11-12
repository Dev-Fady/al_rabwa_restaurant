import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';

/// One page of the customer's order history returned by `GET /orders`.
class OrdersPage {
  const OrdersPage({
    this.orders = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  final List<Order> orders;
  final int currentPage;
  final int lastPage;

  /// Total number of orders across every page.
  final int total;

  bool get isEmpty => orders.isEmpty;

  bool get hasMore => currentPage < lastPage;
}
