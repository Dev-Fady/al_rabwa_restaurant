// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TableListResponse _$TableListResponseFromJson(Map<String, dynamic> json) =>
    TableListResponse(
      success: json['success'] as bool?,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TableModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TableListResponseToJson(TableListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

TableModel _$TableModelFromJson(Map<String, dynamic> json) => TableModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$TableModelToJson(TableModel instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
