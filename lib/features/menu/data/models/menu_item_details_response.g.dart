// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemDetailsResponse _$MenuItemDetailsResponseFromJson(
  Map<String, dynamic> json,
) => MenuItemDetailsResponse(
  success: json['success'] as bool? ?? false,
  message: json['message'] as String? ?? '',
  data: json['data'] == null
      ? null
      : MenuItemModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MenuItemDetailsResponseToJson(
  MenuItemDetailsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.toJson(),
};
