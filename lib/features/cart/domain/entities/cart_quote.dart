import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

/// Server-authoritative totals for the current cart, returned by
/// `POST /api/cart/quote`.
///
/// Prices are recalculated by the backend (tax, service charge, delivery fee
/// and any coupon) so the app never has to duplicate those rules.
class CartQuote {
  const CartQuote({
    this.lines = const [],
    this.coupon,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.serviceCharge = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.addressRequired = false,
    this.acceptingOrdersNow = true,
    this.closedMessage = '',
  });

  final List<CartQuoteLine> lines;
  final CartQuoteCoupon? coupon;
  final double subtotal;
  final double discount;
  final double tax;
  final double serviceCharge;
  final double deliveryFee;
  final double total;

  /// The selected order type needs a delivery address before checkout.
  final bool addressRequired;

  /// Whether the restaurant is accepting orders right now.
  final bool acceptingOrdersNow;

  /// Backend message shown when [acceptingOrdersNow] is false.
  final String closedMessage;

  bool get hasDiscount => discount > 0;

  bool get hasTax => tax > 0;

  bool get hasServiceCharge => serviceCharge > 0;

  bool get hasDeliveryFee => deliveryFee > 0;

  bool get hasCoupon => coupon != null;

  bool get isClosed => !acceptingOrdersNow;
}

/// One quoted cart line. Mirrors the request line, with the price the backend
/// calculated for it.
class CartQuoteLine {
  const CartQuoteLine({
    this.itemId,
    this.name = '',
    this.option,
    this.addons = const [],
    this.quantity = 0,
    this.unitPrice = 0,
    this.total = 0,
    this.note,
  });

  final int? itemId;
  final String name;
  final MenuItemOption? option;
  final List<MenuItemAddon> addons;
  final double quantity;
  final double unitPrice;
  final double total;
  final String? note;

  bool get hasOption => option != null;

  bool get hasAddons => addons.isNotEmpty;

  bool get hasNote => note != null && note!.trim().isNotEmpty;
}

/// Coupon applied to the quote, when the backend returned one.
class CartQuoteCoupon {
  const CartQuoteCoupon({this.code = '', this.discount = 0});

  final String code;
  final double discount;

  bool get hasCode => code.trim().isNotEmpty;
}
