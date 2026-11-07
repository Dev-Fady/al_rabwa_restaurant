// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreInfoResponse _$StoreInfoResponseFromJson(Map<String, dynamic> json) =>
    StoreInfoResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : StoreInfoModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreInfoResponseToJson(StoreInfoResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

StoreInfoModel _$StoreInfoModelFromJson(Map<String, dynamic> json) =>
    StoreInfoModel(
      name: json['name'] == null ? '' : _parseString(json['name']),
      logo: json['logo'] == null ? '' : _parseString(json['logo']),
      email: json['email'] == null ? '' : _parseString(json['email']),
      mobile: json['mobile'] == null ? '' : _parseString(json['mobile']),
      mobile2: json['mobile2'] == null ? '' : _parseString(json['mobile2']),
      address: json['address'] == null ? '' : _parseString(json['address']),
      facebook: json['facebook'] == null ? '' : _parseString(json['facebook']),
      twitter: json['twitter'] == null ? '' : _parseString(json['twitter']),
      instagram: json['instagram'] == null
          ? ''
          : _parseString(json['instagram']),
      youtube: json['youtube'] == null ? '' : _parseString(json['youtube']),
    );

Map<String, dynamic> _$StoreInfoModelToJson(StoreInfoModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'logo': instance.logo,
      'email': instance.email,
      'mobile': instance.mobile,
      'mobile2': instance.mobile2,
      'address': instance.address,
      'facebook': instance.facebook,
      'twitter': instance.twitter,
      'instagram': instance.instagram,
      'youtube': instance.youtube,
    };
