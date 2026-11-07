import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_order.dart';

part 'orders_response.g.dart';

int _parseId(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseString(dynamic value) => value?.toString() ?? '';

/// Orders envelope observed in Postman (`GET /api/orders`, Bearer token).
///
/// Success (HTTP 200):
/// ```json
/// {"success": true, "message": "تم استيراد البيانات بنجاح.",
///  "data": [{"order_id": 5, "name": "فادي اميل",
///   "phone": "01153348553", "email": "Fady@gmail.com",
///   "total": 7080, "status": "checkout", "created_at": "2026/10/14"},
///   {"order_id": 7, "name": null, "phone": null, "email": null,
///    "total": 0, "status": "pending", "created_at": "2026/10/14"}]}
/// ```
///
/// Failure (still HTTP 200):
/// ```json
/// {"success": false, "message": "..."}
/// ```
///
/// Note: contact fields (`name`, `phone`, `email`) may be null and
/// `total` may be an int: both parse tolerantly.
@JsonSerializable()
class OrdersResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;
  final List<OrderModel>? data;

  const OrdersResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$OrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);

  List<UserOrder> toEntities() =>
      data?.map((model) => model.toEntity()).toList() ?? const [];
}

@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'order_id', fromJson: _parseId)
  final int orderId;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String name;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String phone;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String email;
  @JsonKey(fromJson: _parseDouble, defaultValue: 0)
  final double total;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String status;
  @JsonKey(name: 'created_at', fromJson: _parseString, defaultValue: '')
  final String createdAt;

  const OrderModel({
    required this.orderId,
    required this.name,
    required this.phone,
    required this.email,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  UserOrder toEntity() => UserOrder(
    orderId: orderId,
    name: name,
    phone: phone,
    email: email,
    total: total,
    status: status,
    createdAt: createdAt,
  );
}
