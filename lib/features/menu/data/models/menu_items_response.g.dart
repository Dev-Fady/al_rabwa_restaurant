// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_items_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemsResponse _$MenuItemsResponseFromJson(Map<String, dynamic> json) =>
    MenuItemsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] == null
          ? null
          : MenuCategoryRefModel.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MenuItemsResponseToJson(MenuItemsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.map((e) => e.toJson()).toList(),
      'category': instance.category?.toJson(),
    };

MenuCategoryRefModel _$MenuCategoryRefModelFromJson(
  Map<String, dynamic> json,
) => MenuCategoryRefModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  image: json['image'] as String?,
  displayStyle: json['display_style'] as String?,
  itemsCount: (json['items_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$MenuCategoryRefModelToJson(
  MenuCategoryRefModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'display_style': instance.displayStyle,
  'items_count': instance.itemsCount,
};

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      id: (json['id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] == null
          ? null
          : MenuCategoryRefModel.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
      price: json['price'] as num?,
      compareAtPrice: json['compare_at_price'] as num?,
      image: json['image'] as String?,
      video: json['video'] as String?,
      hasLargePhoto: json['has_large_photo'] as bool?,
      soldByWeight: json['sold_by_weight'] as bool?,
      weight: _weightFromJson(json['weight']),
      options: json['options'] as List<dynamic>?,
      addons: json['addons'] as List<dynamic>?,
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'price': instance.price,
      'compare_at_price': instance.compareAtPrice,
      'image': instance.image,
      'video': instance.video,
      'has_large_photo': instance.hasLargePhoto,
      'sold_by_weight': instance.soldByWeight,
      'weight': instance.weight,
      'options': instance.options,
      'addons': instance.addons,
    };
