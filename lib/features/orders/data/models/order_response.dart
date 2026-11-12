import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/orders_page.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_response.g.dart';

/// Envelope of `POST /api/orders?lang=ar`.
///
/// ```json
/// {"data": {"id": 25, "number": 12, "type": {"value": "takeaway",
///   "label": "استلام من المطعم"}, "status": {"value": "pending", ...},
///   "payment": {"method": {"value": "cash", ...}, "status": {...}},
///   "subtotal": 9.75, "tax": 0.975, "service_charge": 0.488,
///   "delivery_fee": 0, "total": 11.213, "items": [...]}}
/// ```
@JsonSerializable(explicitToJson: true)
class OrderResponse {
  @JsonKey(defaultValue: true)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final OrderModel? data;

  const OrderResponse({this.success = true, this.message = '', this.data});

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);

  Order? toEntity() => data?.toEntity();
}

@JsonSerializable(explicitToJson: true)
class OrderModel {
  final int? id;
  final int? number;
  final OrderTypeModel? type;
  final OrderStatusModel? status;
  final OrderPaymentModel? payment;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'customer_phone')
  final String? customerPhone;

  final OrderAddressModel? address;
  final String? table;

  @JsonKey(name: 'car_number')
  final String? carNumber;

  @JsonKey(name: 'company_name')
  final String? companyName;

  final String? notes;

  @JsonKey(name: 'coupon_code')
  final String? couponCode;

  final num? subtotal;
  final num? discount;
  final num? tax;

  @JsonKey(name: 'service_charge')
  final num? serviceCharge;

  @JsonKey(name: 'delivery_fee')
  final num? deliveryFee;

  final num? total;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  final List<OrderItemModel>? items;

  const OrderModel({
    this.id,
    this.number,
    this.type,
    this.status,
    this.payment,
    this.customerName,
    this.customerPhone,
    this.address,
    this.table,
    this.carNumber,
    this.companyName,
    this.notes,
    this.couponCode,
    this.subtotal,
    this.discount,
    this.tax,
    this.serviceCharge,
    this.deliveryFee,
    this.total,
    this.createdAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  Order toEntity() {
    return Order(
      id: id,
      number: number,
      type: type?.toEntity() ?? const OrderTypeInfo(),
      status: status?.toEntity() ?? const OrderStatusInfo(),
      payment: payment?.toEntity() ?? const OrderPaymentInfo(),
      customerName: customerName?.trim() ?? '',
      customerPhone: customerPhone?.trim() ?? '',
      address: address?.toEntity(),
      table: table?.trim() ?? '',
      carNumber: carNumber?.trim() ?? '',
      companyName: companyName?.trim() ?? '',
      notes: notes?.trim() ?? '',
      couponCode: couponCode?.trim() ?? '',
      subtotal: (subtotal ?? 0).toDouble(),
      discount: (discount ?? 0).toDouble(),
      tax: (tax ?? 0).toDouble(),
      serviceCharge: (serviceCharge ?? 0).toDouble(),
      deliveryFee: (deliveryFee ?? 0).toDouble(),
      total: (total ?? 0).toDouble(),
      createdAt: DateTime.tryParse(createdAt ?? ''),
      items: [
        for (final item in items ?? const <OrderItemModel>[]) item.toEntity(),
      ],
    );
  }
}

@JsonSerializable()
class OrderTypeModel {
  final String? value;
  final String? label;

  const OrderTypeModel({this.value, this.label});

  factory OrderTypeModel.fromJson(Map<String, dynamic> json) =>
      _$OrderTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTypeModelToJson(this);

  OrderTypeInfo toEntity() =>
      OrderTypeInfo(value: value?.trim() ?? '', label: label?.trim() ?? '');
}

@JsonSerializable()
class OrderStatusModel {
  final String? value;
  final String? label;

  @JsonKey(name: 'is_open')
  final bool? isOpen;

  final String? message;

  const OrderStatusModel({this.value, this.label, this.isOpen, this.message});

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusModelToJson(this);

  OrderStatusInfo toEntity() => OrderStatusInfo(
    value: value?.trim() ?? '',
    label: label?.trim() ?? '',
    isOpen: isOpen ?? true,
    message: message?.trim() ?? '',
  );
}

@JsonSerializable(explicitToJson: true)
class OrderPaymentModel {
  final OrderPaymentMethodModel? method;
  final OrderPaymentStatusModel? status;

  const OrderPaymentModel({this.method, this.status});

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaymentModelToJson(this);

  OrderPaymentInfo toEntity() => OrderPaymentInfo(
    methodValue: method?.value?.trim() ?? '',
    methodLabel: method?.label?.trim() ?? '',
    statusValue: status?.value?.trim() ?? '',
    statusLabel: status?.label?.trim() ?? '',
  );
}

@JsonSerializable()
class OrderPaymentMethodModel {
  final String? value;
  final String? label;

  const OrderPaymentMethodModel({this.value, this.label});

  factory OrderPaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaymentMethodModelToJson(this);
}

@JsonSerializable()
class OrderPaymentStatusModel {
  final String? value;
  final String? label;

  const OrderPaymentStatusModel({this.value, this.label});

  factory OrderPaymentStatusModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaymentStatusModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderItemModel {
  @JsonKey(name: 'item_id')
  final int? itemId;

  final String? name;
  final String? image;
  final num? quantity;

  @JsonKey(name: 'unit_price')
  final num? unitPrice;

  final num? total;
  final String? note;

  @JsonKey(fromJson: _namesFromJson)
  final List<String>? options;

  @JsonKey(fromJson: _namesFromJson)
  final List<String>? addons;

  const OrderItemModel({
    this.itemId,
    this.name,
    this.image,
    this.quantity,
    this.unitPrice,
    this.total,
    this.note,
    this.options,
    this.addons,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItem toEntity() => OrderItem(
    itemId: itemId,
    name: name?.trim() ?? '',
    image: image?.trim() ?? '',
    quantity: (quantity ?? 0).toDouble(),
    unitPrice: (unitPrice ?? 0).toDouble(),
    total: (total ?? 0).toDouble(),
    note: note?.trim() ?? '',
    options: List.unmodifiable(options ?? const <String>[]),
    addons: List.unmodifiable(addons ?? const <String>[]),
  );
}

@JsonSerializable(explicitToJson: true)
class OrderAddressModel {
  final String? area;
  final String? street;
  final String? building;
  final String? notes;
  final double? latitude;
  final double? longitude;

  const OrderAddressModel({
    this.area,
    this.street,
    this.building,
    this.notes,
    this.latitude,
    this.longitude,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) =>
      _$OrderAddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderAddressModelToJson(this);

  OrderAddress toEntity() => OrderAddress(
    area: area?.trim() ?? '',
    street: street?.trim() ?? '',
    building: building?.trim() ?? '',
    notes: notes?.trim() ?? '',
    latitude: latitude,
    longitude: longitude,
  );
}

/// Envelope of `GET /api/orders?lang=ar&status=current&page=1`.
///
/// ```json
/// {"data": [{"id": 25, "number": 12, ...}],
///  "links": {"first": "...", "last": "...", "prev": null, "next": null},
///  "meta": {"current_page": 1, "last_page": 1, "per_page": 20, "total": 5}}
/// ```
@JsonSerializable(explicitToJson: true)
class OrderListResponse {
  final bool? success;

  @JsonKey(defaultValue: '')
  final String message;

  final List<OrderModel>? data;
  final OrderPaginationMetaModel? meta;

  const OrderListResponse({
    this.success,
    this.message = '',
    this.data,
    this.meta,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListResponseToJson(this);

  OrdersPage toEntity() {
    final orders = [
      for (final order in data ?? const <OrderModel>[]) order.toEntity(),
    ];

    return OrdersPage(
      orders: List.unmodifiable(orders),
      currentPage: meta?.currentPage ?? 1,
      lastPage: meta?.lastPage ?? 1,
      total: meta?.total ?? orders.length,
    );
  }
}

@JsonSerializable()
class OrderPaginationMetaModel {
  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'per_page')
  final int? perPage;

  final int? total;
  final int? from;
  final int? to;

  const OrderPaginationMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
  });

  factory OrderPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$OrderPaginationMetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaginationMetaModelToJson(this);
}

/// The order response returns option/add-on names as strings; tolerate objects
/// too so a backend shape change does not drop the selections.
List<String> _namesFromJson(Object? value) {
  if (value is! List) return const [];

  final names = <String>[];
  for (final entry in value) {
    final String name;
    if (entry is String) {
      name = entry.trim();
    } else if (entry is Map) {
      name = entry['name']?.toString().trim() ?? '';
    } else {
      name = '';
    }
    if (name.isNotEmpty) names.add(name);
  }
  return names;
}
