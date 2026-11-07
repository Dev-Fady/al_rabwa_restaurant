import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/store_info.dart';

part 'store_info_response.g.dart';

String _parseString(dynamic value) => value?.toString() ?? '';

/// Store settings envelope observed in Postman (`GET /api/settings`).
///
/// Success (HTTP 200):
/// ```json
/// {"success": true, "message": "تم استيراد البيانات بنجاح.",
///  "data": {"name": "وادي الملكات", "logo": "https://...",
///   "email": "info@wadi-almalekat.com", "mobile": "97433363803",
///   "mobile2": "974", "address": "طريق سلوى ,الدوحة ,قطر",
///   "facebook": null, "twitter": null, "instagram": null, "youtube": null}}
/// ```
///
/// Failure (still HTTP 200):
/// ```json
/// {"success": false, "message": "..."}
/// ```
@JsonSerializable()
class StoreInfoResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;
  final StoreInfoModel? data;

  const StoreInfoResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoreInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoreInfoResponseToJson(this);

  StoreInfo toEntity() => data?.toEntity() ?? const StoreInfo();
}

@JsonSerializable()
class StoreInfoModel {
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String name;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String logo;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String email;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String mobile;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String mobile2;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String address;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String facebook;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String twitter;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String instagram;
  @JsonKey(fromJson: _parseString, defaultValue: '')
  final String youtube;

  const StoreInfoModel({
    required this.name,
    required this.logo,
    required this.email,
    required this.mobile,
    required this.mobile2,
    required this.address,
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.youtube,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) =>
      _$StoreInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreInfoModelToJson(this);

  StoreInfo toEntity() => StoreInfo(
    name: name,
    logo: logo,
    email: email,
    mobile: mobile,
    mobile2: mobile2,
    address: address,
    facebook: facebook,
    twitter: twitter,
    instagram: instagram,
    youtube: youtube,
  );
}
