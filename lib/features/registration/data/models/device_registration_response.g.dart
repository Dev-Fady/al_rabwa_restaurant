// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRegistrationResponse _$DeviceRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => DeviceRegistrationResponse(
  success: json['success'] as bool?,
  message: json['message'] as String? ?? '',
  data: json['data'] == null
      ? null
      : DeviceModel.fromJson(json['data'] as Map<String, dynamic>),
  token: json['token'] as String? ?? '',
);

Map<String, dynamic> _$DeviceRegistrationResponseToJson(
  DeviceRegistrationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'token': instance.token,
};

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => DeviceModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  locale: json['locale'] as String?,
  hasPushToken: json['has_push_token'] as bool?,
);

Map<String, dynamic> _$DeviceModelToJson(DeviceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'locale': instance.locale,
      'has_push_token': instance.hasPushToken,
    };
