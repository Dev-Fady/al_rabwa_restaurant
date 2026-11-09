import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/device_session.dart';

part 'device_registration_response.g.dart';

/// Envelope of `POST /api/device`.
///
/// ```json
/// {"data": {"id": 17, "name": "جودة", "phone": "+974 555 1234",
///   "email": null, "locale": "ar", "has_push_token": false},
///  "token": "IoKjpoomXZwOGK2xrJlJnr37hXDilq2FKws9XZSwsGS2bINWtJfrgJlm8dZxvTtOML"}
/// ```
@JsonSerializable()
class DeviceRegistrationResponse {
  /// The live API omits `success` on a successful registration, so an
  /// explicit `false` is the only reliable failure signal.
  final bool? success;

  @JsonKey(defaultValue: '')
  final String message;

  final DeviceModel? data;

  @JsonKey(defaultValue: '')
  final String token;

  const DeviceRegistrationResponse({
    this.success,
    this.message = '',
    this.data,
    this.token = '',
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceRegistrationResponseToJson(this);

  DeviceSession? toEntity() {
    final device = data;
    final bearer = token.trim();
    if (device == null || bearer.isEmpty) return null;

    return DeviceSession(
      token: bearer,
      id: device.id,
      name: device.name?.trim() ?? '',
      phone: device.phone?.trim() ?? '',
      email: device.email?.trim(),
      locale: device.locale?.trim().isNotEmpty == true
          ? device.locale!.trim()
          : 'ar',
      hasPushToken: device.hasPushToken ?? false,
    );
  }
}

@JsonSerializable()
class DeviceModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? locale;

  @JsonKey(name: 'has_push_token')
  final bool? hasPushToken;

  const DeviceModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.locale,
    this.hasPushToken,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);
}
