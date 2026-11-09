// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      success: json['success'] as bool?,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : AddressModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AddressListResponse _$AddressListResponseFromJson(Map<String, dynamic> json) =>
    AddressListResponse(
      success: json['success'] as bool?,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddressListResponseToJson(
  AddressListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: (json['id'] as num?)?.toInt(),
  kind: json['kind'] as String?,
  kindLabel: json['kind_label'] as String?,
  label: json['label'] as String?,
  title: json['title'] as String?,
  summary: json['summary'] as String?,
  deliveryZone: json['delivery_zone'],
  isDeliverable: json['is_deliverable'] as bool?,
  area: json['area'] as String?,
  street: json['street'] as String?,
  building: json['building'] as String?,
  notes: json['notes'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  lastUsedAt: json['last_used_at'] as String?,
  isDefault: json['is_default'] as bool?,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'kind_label': instance.kindLabel,
      'label': instance.label,
      'title': instance.title,
      'summary': instance.summary,
      'delivery_zone': instance.deliveryZone,
      'is_deliverable': instance.isDeliverable,
      'area': instance.area,
      'street': instance.street,
      'building': instance.building,
      'notes': instance.notes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'last_used_at': instance.lastUsedAt,
      'is_default': instance.isDefault,
    };
