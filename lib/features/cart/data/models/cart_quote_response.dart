import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_quote_response.g.dart';

/// Envelope of `POST /api/cart/quote?lang=ar`.
///
/// ```json
/// {"data": {"lines": [...], "coupon": null, "subtotal": 9.75,
///   "discount": 0, "tax": 0.975, "service_charge": 0.488,
///   "delivery_fee": 0, "total": 11.213, "address_required": false,
///   "accepting_orders_now": true, "closed_message": null}}
/// ```
@JsonSerializable(explicitToJson: true)
class CartQuoteResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final CartQuoteModel? data;

  const CartQuoteResponse({this.success = false, this.message = '', this.data});

  factory CartQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteResponseToJson(this);

  CartQuote? toEntity() => data?.toEntity();
}

@JsonSerializable(explicitToJson: true)
class CartQuoteModel {
  final List<CartQuoteLineModel>? lines;

  @JsonKey(fromJson: _couponFromJson)
  final CartQuoteCouponModel? coupon;

  final num? subtotal;
  final num? discount;
  final num? tax;

  @JsonKey(name: 'service_charge')
  final num? serviceCharge;

  @JsonKey(name: 'delivery_fee')
  final num? deliveryFee;

  final num? total;

  @JsonKey(name: 'address_required')
  final bool? addressRequired;

  @JsonKey(name: 'accepting_orders_now')
  final bool? acceptingOrdersNow;

  @JsonKey(name: 'closed_message')
  final String? closedMessage;

  const CartQuoteModel({
    this.lines,
    this.coupon,
    this.subtotal,
    this.discount,
    this.tax,
    this.serviceCharge,
    this.deliveryFee,
    this.total,
    this.addressRequired,
    this.acceptingOrdersNow,
    this.closedMessage,
  });

  factory CartQuoteModel.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteModelToJson(this);

  CartQuote toEntity() {
    return CartQuote(
      lines: [
        for (final line in lines ?? const <CartQuoteLineModel>[])
          line.toEntity(),
      ],
      coupon: coupon?.toEntity(),
      subtotal: (subtotal ?? 0).toDouble(),
      discount: (discount ?? 0).toDouble(),
      tax: (tax ?? 0).toDouble(),
      serviceCharge: (serviceCharge ?? 0).toDouble(),
      deliveryFee: (deliveryFee ?? 0).toDouble(),
      total: (total ?? 0).toDouble(),
      addressRequired: addressRequired ?? false,
      acceptingOrdersNow: acceptingOrdersNow ?? true,
      closedMessage: closedMessage?.trim() ?? '',
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CartQuoteLineModel {
  @JsonKey(name: 'item_id')
  final int? itemId;

  final String? name;
  final CartQuoteOptionModel? option;
  final List<CartQuoteAddonModel>? addons;
  final num? quantity;

  @JsonKey(name: 'unit_price')
  final num? unitPrice;

  final num? total;
  final String? note;

  const CartQuoteLineModel({
    this.itemId,
    this.name,
    this.option,
    this.addons,
    this.quantity,
    this.unitPrice,
    this.total,
    this.note,
  });

  factory CartQuoteLineModel.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteLineModelToJson(this);

  CartQuoteLine toEntity() {
    return CartQuoteLine(
      itemId: itemId,
      name: name?.trim() ?? '',
      option: option?.toEntity(),
      addons: [
        for (final addon in addons ?? const <CartQuoteAddonModel>[])
          addon.toEntity(),
      ],
      quantity: (quantity ?? 0).toDouble(),
      unitPrice: (unitPrice ?? 0).toDouble(),
      total: (total ?? 0).toDouble(),
      note: note?.trim(),
    );
  }
}

@JsonSerializable()
class CartQuoteOptionModel {
  final int? id;
  final String? name;
  final num? price;

  const CartQuoteOptionModel({this.id, this.name, this.price});

  factory CartQuoteOptionModel.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteOptionModelToJson(this);

  MenuItemOption toEntity() => MenuItemOption(
    id: id,
    name: name?.trim() ?? '',
    price: (price ?? 0).toDouble(),
  );
}

@JsonSerializable()
class CartQuoteAddonModel {
  final int? id;
  final String? name;
  final num? price;

  const CartQuoteAddonModel({this.id, this.name, this.price});

  factory CartQuoteAddonModel.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteAddonModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteAddonModelToJson(this);

  MenuItemAddon toEntity() => MenuItemAddon(
    id: id,
    name: name?.trim() ?? '',
    price: (price ?? 0).toDouble(),
  );
}

@JsonSerializable()
class CartQuoteCouponModel {
  final String? code;
  final num? discount;

  const CartQuoteCouponModel({this.code, this.discount});

  factory CartQuoteCouponModel.fromJson(Map<String, dynamic> json) =>
      _$CartQuoteCouponModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartQuoteCouponModelToJson(this);

  CartQuoteCoupon toEntity() => CartQuoteCoupon(
    code: code?.trim() ?? '',
    discount: (discount ?? 0).toDouble(),
  );
}

/// The live API returns either `null`, a coupon code string, or an object.
CartQuoteCouponModel? _couponFromJson(Object? value) {
  if (value is Map) {
    return CartQuoteCouponModel.fromJson(Map<String, dynamic>.from(value));
  }
  if (value is String && value.trim().isNotEmpty) {
    return CartQuoteCouponModel(code: value.trim());
  }
  return null;
}
