// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : OrderModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num?)?.toInt(),
  number: (json['number'] as num?)?.toInt(),
  type: json['type'] == null
      ? null
      : OrderTypeModel.fromJson(json['type'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : OrderStatusModel.fromJson(json['status'] as Map<String, dynamic>),
  payment: json['payment'] == null
      ? null
      : OrderPaymentModel.fromJson(json['payment'] as Map<String, dynamic>),
  customerName: json['customer_name'] as String?,
  customerPhone: json['customer_phone'] as String?,
  notes: json['notes'] as String?,
  couponCode: json['coupon_code'] as String?,
  subtotal: json['subtotal'] as num?,
  discount: json['discount'] as num?,
  tax: json['tax'] as num?,
  serviceCharge: json['service_charge'] as num?,
  deliveryFee: json['delivery_fee'] as num?,
  total: json['total'] as num?,
  createdAt: json['created_at'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'type': instance.type?.toJson(),
      'status': instance.status?.toJson(),
      'payment': instance.payment?.toJson(),
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'notes': instance.notes,
      'coupon_code': instance.couponCode,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'service_charge': instance.serviceCharge,
      'delivery_fee': instance.deliveryFee,
      'total': instance.total,
      'created_at': instance.createdAt,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

OrderTypeModel _$OrderTypeModelFromJson(Map<String, dynamic> json) =>
    OrderTypeModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$OrderTypeModelToJson(OrderTypeModel instance) =>
    <String, dynamic>{'value': instance.value, 'label': instance.label};

OrderStatusModel _$OrderStatusModelFromJson(Map<String, dynamic> json) =>
    OrderStatusModel(
      value: json['value'] as String?,
      label: json['label'] as String?,
      isOpen: json['is_open'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$OrderStatusModelToJson(OrderStatusModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'is_open': instance.isOpen,
      'message': instance.message,
    };

OrderPaymentModel _$OrderPaymentModelFromJson(Map<String, dynamic> json) =>
    OrderPaymentModel(
      method: json['method'] == null
          ? null
          : OrderPaymentMethodModel.fromJson(
              json['method'] as Map<String, dynamic>,
            ),
      status: json['status'] == null
          ? null
          : OrderPaymentStatusModel.fromJson(
              json['status'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$OrderPaymentModelToJson(OrderPaymentModel instance) =>
    <String, dynamic>{
      'method': instance.method?.toJson(),
      'status': instance.status?.toJson(),
    };

OrderPaymentMethodModel _$OrderPaymentMethodModelFromJson(
  Map<String, dynamic> json,
) => OrderPaymentMethodModel(
  value: json['value'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$OrderPaymentMethodModelToJson(
  OrderPaymentMethodModel instance,
) => <String, dynamic>{'value': instance.value, 'label': instance.label};

OrderPaymentStatusModel _$OrderPaymentStatusModelFromJson(
  Map<String, dynamic> json,
) => OrderPaymentStatusModel(
  value: json['value'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$OrderPaymentStatusModelToJson(
  OrderPaymentStatusModel instance,
) => <String, dynamic>{'value': instance.value, 'label': instance.label};

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      itemId: (json['item_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      quantity: json['quantity'] as num?,
      unitPrice: json['unit_price'] as num?,
      total: json['total'] as num?,
      note: json['note'] as String?,
      options: _namesFromJson(json['options']),
      addons: _namesFromJson(json['addons']),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'name': instance.name,
      'image': instance.image,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total': instance.total,
      'note': instance.note,
      'options': instance.options,
      'addons': instance.addons,
    };
