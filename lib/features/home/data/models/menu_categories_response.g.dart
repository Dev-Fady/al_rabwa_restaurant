// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_categories_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuCategoriesResponse _$MenuCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => MenuCategoriesResponse(
  success: json['success'] as bool? ?? false,
  message: json['message'] as String? ?? '',
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => MenuCategoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuCategoriesResponseToJson(
  MenuCategoriesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

MenuCategoryModel _$MenuCategoryModelFromJson(Map<String, dynamic> json) =>
    MenuCategoryModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      displayStyle: json['display_style'] as String?,
      itemsCount: (json['items_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MenuCategoryModelToJson(MenuCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'display_style': instance.displayStyle,
      'items_count': instance.itemsCount,
    };
