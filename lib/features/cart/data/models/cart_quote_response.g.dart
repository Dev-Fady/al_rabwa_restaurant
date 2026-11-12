// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartQuoteResponse _$CartQuoteResponseFromJson(Map<String, dynamic> json) =>
    CartQuoteResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : CartQuoteModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartQuoteResponseToJson(CartQuoteResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

CartQuoteModel _$CartQuoteModelFromJson(Map<String, dynamic> json) =>
    CartQuoteModel(
      lines: (json['lines'] as List<dynamic>?)
          ?.map((e) => CartQuoteLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      coupon: _couponFromJson(json['coupon']),
      subtotal: json['subtotal'] as num?,
      discount: json['discount'] as num?,
      tax: json['tax'] as num?,
      serviceCharge: json['service_charge'] as num?,
      deliveryFee: json['delivery_fee'] as num?,
      total: json['total'] as num?,
      addressRequired: json['address_required'] as bool?,
      acceptingOrdersNow: json['accepting_orders_now'] as bool?,
      closedMessage: json['closed_message'] as String?,
    );

Map<String, dynamic> _$CartQuoteModelToJson(CartQuoteModel instance) =>
    <String, dynamic>{
      'lines': instance.lines?.map((e) => e.toJson()).toList(),
      'coupon': instance.coupon?.toJson(),
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'service_charge': instance.serviceCharge,
      'delivery_fee': instance.deliveryFee,
      'total': instance.total,
      'address_required': instance.addressRequired,
      'accepting_orders_now': instance.acceptingOrdersNow,
      'closed_message': instance.closedMessage,
    };

CartQuoteLineModel _$CartQuoteLineModelFromJson(Map<String, dynamic> json) =>
    CartQuoteLineModel(
      itemId: (json['item_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      option: json['option'] == null
          ? null
          : CartQuoteOptionModel.fromJson(
              json['option'] as Map<String, dynamic>,
            ),
      addons: (json['addons'] as List<dynamic>?)
          ?.map((e) => CartQuoteAddonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quantity: json['quantity'] as num?,
      unitPrice: json['unit_price'] as num?,
      total: json['total'] as num?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CartQuoteLineModelToJson(CartQuoteLineModel instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'option': instance.option?.toJson(),
      'addons': instance.addons?.map((e) => e.toJson()).toList(),
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total': instance.total,
      'note': instance.note,
    };

CartQuoteOptionModel _$CartQuoteOptionModelFromJson(
  Map<String, dynamic> json,
) => CartQuoteOptionModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  price: json['price'] as num?,
);

Map<String, dynamic> _$CartQuoteOptionModelToJson(
  CartQuoteOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
};

CartQuoteAddonModel _$CartQuoteAddonModelFromJson(Map<String, dynamic> json) =>
    CartQuoteAddonModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      price: json['price'] as num?,
    );

Map<String, dynamic> _$CartQuoteAddonModelToJson(
  CartQuoteAddonModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
};

CartQuoteCouponModel _$CartQuoteCouponModelFromJson(
  Map<String, dynamic> json,
) => CartQuoteCouponModel(
  code: json['code'] as String?,
  discount: json['discount'] as num?,
);

Map<String, dynamic> _$CartQuoteCouponModelToJson(
  CartQuoteCouponModel instance,
) => <String, dynamic>{'code': instance.code, 'discount': instance.discount};
