/// Everything the checkout sends to `POST /orders` besides the cart lines.
class OrderDraft {
  const OrderDraft({
    required this.orderType,
    required this.paymentMethod,
    this.addressId,
    this.diningTableId,
    this.notes = '',
  });

  /// Order types the app can place today. Dine-in sends the chosen table id.
  static const Set<String> supportedOrderTypes = {
    'delivery',
    'takeaway',
    'dine_in',
  };

  final String orderType;
  final String paymentMethod;
  final int? addressId;
  final int? diningTableId;
  final String notes;

  bool get isDelivery => orderType == 'delivery';

  bool get isDineIn => orderType == 'dine_in';

  bool get requiresAddress => isDelivery;

  bool get requiresTable => isDineIn;

  bool get isSupported => supportedOrderTypes.contains(orderType);

  String get trimmedNotes => notes.trim();
}
