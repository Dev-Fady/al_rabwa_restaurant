/// Single order of the authenticated user.
class UserOrder {
  final int orderId;
  final String name;
  final String phone;
  final String email;

  /// Order total from the backend.
  final double total;

  /// Raw backend status: `"checkout"` (placed) or `"pending"` (open).
  final String status;
  final String createdAt;

  const UserOrder({
    required this.orderId,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.total = 0,
    this.status = '',
    this.createdAt = '',
  });

  /// The open cart surfaces as an order with `status: "pending"`.
  bool get isPending => status == 'pending';

  bool get isPlaced => status == 'checkout';
}
