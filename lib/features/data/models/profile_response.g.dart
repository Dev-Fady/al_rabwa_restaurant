// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : ProfileUserModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ProfileUserModel _$ProfileUserModelFromJson(Map<String, dynamic> json) =>
    ProfileUserModel(
      id: _parseId(json['id']),
      name: json['name'] == null ? '' : _parseString(json['name']),
      email: json['email'] == null ? '' : _parseString(json['email']),
      mobile: json['mobile'] == null ? '' : _parseString(json['mobile']),
      lang: json['lang'] == null ? 'ar' : _parseString(json['lang']),
    );

Map<String, dynamic> _$ProfileUserModelToJson(ProfileUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mobile': instance.mobile,
      'lang': instance.lang,
    };
