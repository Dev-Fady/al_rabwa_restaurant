// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersResponse _$OrdersResponseFromJson(Map<String, dynamic> json) =>
    OrdersResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrdersResponseToJson(OrdersResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  orderId: _parseId(json['order_id']),
  name: json['name'] == null ? '' : _parseString(json['name']),
  phone: json['phone'] == null ? '' : _parseString(json['phone']),
  email: json['email'] == null ? '' : _parseString(json['email']),
  total: json['total'] == null ? 0 : _parseDouble(json['total']),
  status: json['status'] == null ? '' : _parseString(json['status']),
  createdAt: json['created_at'] == null ? '' : _parseString(json['created_at']),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'total': instance.total,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
