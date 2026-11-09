import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/geo_point.dart';

part 'address_response.g.dart';

/// Envelope of `POST /api/addresses`.
///
/// ```json
/// {"data": {"id": 1, "kind": "home", "kind_label": "المنزل",
///   "label": "البيت", "title": "البيت",
///   "summary": "السد، شارع 901، مبنى 35، الطابق 2",
///   "delivery_zone": null, "is_deliverable": true, "area": "السد",
///   "street": "شارع 901", "building": "مبنى 35، الطابق 2",
///   "notes": "الباب الأخضر", "latitude": 25.2854, "longitude": 51.531,
///   "last_used_at": "2026-11-09T13:32:18+00:00"}}
/// ```
///
/// The live API omits `success`, so an explicit `false` is the only reliable
/// failure signal (same convention as the other endpoints).
@JsonSerializable()
class AddressResponse {
  final bool? success;

  @JsonKey(defaultValue: '')
  final String message;

  final AddressModel? data;

  const AddressResponse({this.success, this.message = '', this.data});

  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);

  Address? toEntity() => data?.toEntity();
}

/// Envelope of `GET /api/addresses`.
///
/// ```json
/// {"data": [
///   {"id": 3, "kind": "home", "kind_label": "المنزل",
///    "label": "الشركة", "title": "الشركة",
///    "summary": "السد، شارع 901، مبنى 35، الطابق 2",
///    "delivery_zone": null, "is_deliverable": true, "area": "السد",
///    "street": "شارع 901", "building": "مبنى 35، الطابق 2",
///    "notes": "الباب الأخضر", "latitude": 25.2854, "longitude": 51.531,
///    "last_used_at": "2026-11-09T15:47:24+00:00"}
/// ]}
/// ```
@JsonSerializable()
class AddressListResponse {
  final bool? success;

  @JsonKey(defaultValue: '')
  final String message;

  final List<AddressModel>? data;

  const AddressListResponse({this.success, this.message = '', this.data});

  factory AddressListResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddressListResponseToJson(this);

  List<Address> toEntities() =>
      data?.map((address) => address.toEntity()).toList(growable: false) ??
      const [];
}

@JsonSerializable()
class AddressModel {
  final int? id;
  final String? kind;

  @JsonKey(name: 'kind_label')
  final String? kindLabel;

  final String? label;
  final String? title;
  final String? summary;

  /// `null`, or an object/string describing the matched delivery zone. Its
  /// exact shape is not part of the contract, so it stays untyped here and is
  /// narrowed in [toEntity].
  @JsonKey(name: 'delivery_zone')
  final dynamic deliveryZone;

  @JsonKey(name: 'is_deliverable')
  final bool? isDeliverable;

  final String? area;
  final String? street;
  final String? building;
  final String? notes;
  final double? latitude;
  final double? longitude;

  @JsonKey(name: 'last_used_at')
  final String? lastUsedAt;

  const AddressModel({
    this.id,
    this.kind,
    this.kindLabel,
    this.label,
    this.title,
    this.summary,
    this.deliveryZone,
    this.isDeliverable,
    this.area,
    this.street,
    this.building,
    this.notes,
    this.latitude,
    this.longitude,
    this.lastUsedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  Address toEntity() {
    final lat = latitude;
    final lng = longitude;

    return Address(
      id: id,
      kind: AddressKind.fromApi(kind),
      kindLabel: kindLabel?.trim() ?? '',
      label: label?.trim() ?? '',
      title: title?.trim() ?? '',
      summary: summary?.trim() ?? '',
      deliveryZone: _deliveryZoneName(deliveryZone),
      // Missing flag means the API did not reject the coordinate.
      isDeliverable: isDeliverable ?? true,
      area: area?.trim() ?? '',
      street: street?.trim() ?? '',
      building: building?.trim() ?? '',
      notes: notes?.trim() ?? '',
      point: lat == null || lng == null
          ? null
          : GeoPoint(latitude: lat, longitude: lng),
      lastUsedAt: lastUsedAt == null ? null : DateTime.tryParse(lastUsedAt!),
    );
  }

  /// Accepts a plain string or an object carrying the zone's display name.
  String? _deliveryZoneName(dynamic raw) {
    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? null : value;
    }
    if (raw is Map) {
      for (final key in const ['name', 'title', 'label']) {
        final value = raw[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }
}
