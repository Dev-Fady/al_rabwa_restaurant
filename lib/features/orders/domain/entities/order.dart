/// A created order returned by `POST /orders`.
class Order {
  const Order({
    this.id,
    this.number,
    this.type = const OrderTypeInfo(),
    this.status = const OrderStatusInfo(),
    this.payment = const OrderPaymentInfo(),
    this.customerName = '',
    this.customerPhone = '',
    this.notes = '',
    this.couponCode = '',
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.serviceCharge = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.createdAt,
    this.items = const [],
  });

  final int? id;

  /// Human-friendly order number shown to the customer.
  final int? number;

  final OrderTypeInfo type;
  final OrderStatusInfo status;
  final OrderPaymentInfo payment;

  final String customerName;
  final String customerPhone;
  final String notes;
  final String couponCode;

  final double subtotal;
  final double discount;
  final double tax;
  final double serviceCharge;
  final double deliveryFee;
  final double total;

  final DateTime? createdAt;
  final List<OrderItem> items;

  bool get hasDiscount => discount > 0;

  bool get hasTax => tax > 0;

  bool get hasServiceCharge => serviceCharge > 0;

  bool get hasDeliveryFee => deliveryFee > 0;

  /// Number to show in the confirmation, preferring the backend order number.
  int? get displayNumber => number ?? id;
}

class OrderTypeInfo {
  const OrderTypeInfo({this.value = '', this.label = ''});

  final String value;
  final String label;

  String get displayLabel => label.trim().isNotEmpty ? label.trim() : value;
}

class OrderStatusInfo {
  const OrderStatusInfo({
    this.value = '',
    this.label = '',
    this.isOpen = true,
    this.message = '',
  });

  final String value;
  final String label;
  final bool isOpen;

  /// Localized confirmation message such as "We received your order #12".
  final String message;

  String get displayLabel => label.trim().isNotEmpty ? label.trim() : value;

  bool get hasMessage => message.trim().isNotEmpty;
}

class OrderPaymentInfo {
  const OrderPaymentInfo({
    this.methodValue = '',
    this.methodLabel = '',
    this.statusValue = '',
    this.statusLabel = '',
  });

  final String methodValue;
  final String methodLabel;
  final String statusValue;
  final String statusLabel;

  String get displayMethod =>
      methodLabel.trim().isNotEmpty ? methodLabel.trim() : methodValue;

  String get displayStatus =>
      statusLabel.trim().isNotEmpty ? statusLabel.trim() : statusValue;
}

class OrderItem {
  const OrderItem({
    this.itemId,
    this.name = '',
    this.image = '',
    this.quantity = 0,
    this.unitPrice = 0,
    this.total = 0,
    this.note = '',
    this.options = const [],
    this.addons = const [],
  });

  final int? itemId;
  final String name;
  final String image;
  final double quantity;
  final double unitPrice;
  final double total;
  final String note;
  final List<String> options;
  final List<String> addons;

  bool get hasNote => note.trim().isNotEmpty;

  bool get hasOptions => options.isNotEmpty;

  bool get hasAddons => addons.isNotEmpty;
}
