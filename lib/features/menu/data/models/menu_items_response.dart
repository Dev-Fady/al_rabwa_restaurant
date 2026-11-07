import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/menu_category_items.dart';
import '../../domain/entities/menu_item.dart';

part 'menu_items_response.g.dart';

/// Envelope of `GET /api/categories/{id}/items?lang=ar`.
///
/// ```json
/// {"data": [{"id": 40, "name": "دجاج مسحب (700 غ)", "price": 35, ...}],
///  "category": {"id": 11, "name": "مشاوي علي الفحم",
///    "display_style": "large", "items_count": 12}}
/// ```
@JsonSerializable(explicitToJson: true)
class MenuItemsResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final List<MenuItemModel>? data;
  final MenuCategoryRefModel? category;

  const MenuItemsResponse({
    this.success = false,
    this.message = '',
    this.data,
    this.category,
  });

  factory MenuItemsResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuItemsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemsResponseToJson(this);

  MenuCategoryItems toEntity() => MenuCategoryItems(
    items: [
      for (final item in data ?? const <MenuItemModel>[]) item.toEntity(),
    ],
    category: category?.toEntity(),
  );
}

@JsonSerializable()
class MenuCategoryRefModel {
  final int? id;
  final String? name;
  final String? image;

  @JsonKey(name: 'display_style')
  final String? displayStyle;

  @JsonKey(name: 'items_count')
  final int? itemsCount;

  const MenuCategoryRefModel({
    this.id,
    this.name,
    this.image,
    this.displayStyle,
    this.itemsCount,
  });

  factory MenuCategoryRefModel.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryRefModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryRefModelToJson(this);

  MenuCategory toEntity() => MenuCategory(
    id: id,
    name: name?.trim() ?? '',
    image: image?.trim() ?? '',
    displayStyle: categoryDisplayStyleFrom(displayStyle),
    itemsCount: itemsCount == null || itemsCount! < 0 ? 0 : itemsCount!,
  );
}

@JsonSerializable()
class MenuItemModel {
  final int? id;

  @JsonKey(name: 'category_id')
  final int? categoryId;

  final String? name;
  final String? description;
  final num? price;

  @JsonKey(name: 'compare_at_price')
  final num? compareAtPrice;

  final String? image;
  final String? video;

  @JsonKey(name: 'has_large_photo')
  final bool? hasLargePhoto;

  @JsonKey(name: 'sold_by_weight')
  final bool? soldByWeight;

  final num? weight;
  final List<dynamic>? options;
  final List<dynamic>? addons;

  const MenuItemModel({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.price,
    this.compareAtPrice,
    this.image,
    this.video,
    this.hasLargePhoto,
    this.soldByWeight,
    this.weight,
    this.options,
    this.addons,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  MenuItem toEntity() => MenuItem(
    id: id,
    categoryId: categoryId,
    name: name?.trim() ?? '',
    description: description?.trim() ?? '',
    price: (price ?? 0).toDouble(),
    compareAtPrice: compareAtPrice?.toDouble(),
    image: image?.trim() ?? '',
    video: video ?? '',
    hasLargePhoto: hasLargePhoto ?? false,
    soldByWeight: soldByWeight ?? false,
    weight: weight?.toDouble(),
    hasOptions: (options ?? const []).isNotEmpty,
    hasAddons: (addons ?? const []).isNotEmpty,
  );
}
