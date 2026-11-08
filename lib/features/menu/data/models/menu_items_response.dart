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

  /// Only present on the single-item endpoint (`GET /items/{id}`).
  final MenuCategoryRefModel? category;

  final num? price;

  @JsonKey(name: 'compare_at_price')
  final num? compareAtPrice;

  final String? image;
  final String? video;

  @JsonKey(name: 'has_large_photo')
  final bool? hasLargePhoto;

  @JsonKey(name: 'sold_by_weight')
  final bool? soldByWeight;

  /// The live API sends either a plain number or, for dishes sold by weight,
  /// a selectable range such as `{"min": 0.25, "max": 10, "step": 0.25}`.
  @JsonKey(name: 'weight', fromJson: _weightFromJson)
  final MenuItemWeightModel? weight;

  final List<MenuItemOptionModel>? options;
  final List<MenuItemAddonModel>? addons;

  const MenuItemModel({
    this.id,
    this.categoryId,
    this.name,
    this.description,
    this.category,
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
    weightRange: weight?.toEntity(),
    options: [
      for (final option in options ?? const <MenuItemOptionModel>[])
        option.toEntity(),
    ],
    addons: [
      for (final addon in addons ?? const <MenuItemAddonModel>[])
        addon.toEntity(),
    ],
  );
}

/// One portion choice of a dish, e.g. `{"id": 8, "name": "نفرين", "price": 30}`.
@JsonSerializable()
class MenuItemOptionModel {
  final int? id;
  final String? name;
  final num? price;

  const MenuItemOptionModel({this.id, this.name, this.price});

  factory MenuItemOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemOptionModelToJson(this);

  MenuItemOption toEntity() => MenuItemOption(
    id: id,
    name: name?.trim() ?? '',
    price: (price ?? 0).toDouble(),
  );
}

/// An extra added to a dish, e.g. `{"id": 34, "name": "إضافة أرز", "price": 5}`.
@JsonSerializable()
class MenuItemAddonModel {
  final int? id;
  final String? name;
  final num? price;
  final String? image;

  const MenuItemAddonModel({this.id, this.name, this.price, this.image});

  factory MenuItemAddonModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemAddonModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemAddonModelToJson(this);

  MenuItemAddon toEntity() => MenuItemAddon(
    id: id,
    name: name?.trim() ?? '',
    price: (price ?? 0).toDouble(),
    image: image?.trim() ?? '',
  );
}

/// The `{min, max, step}` range of dishes sold by weight.
@JsonSerializable()
class MenuItemWeightModel {
  final num? min;
  final num? max;
  final num? step;

  const MenuItemWeightModel({this.min, this.max, this.step});

  factory MenuItemWeightModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemWeightModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemWeightModelToJson(this);

  MenuItemWeight? toEntity() {
    final minValue = min?.toDouble();
    if (minValue == null || minValue <= 0) return null;
    final maxValue = max?.toDouble() ?? minValue;
    final stepValue = step?.toDouble() ?? minValue;

    return MenuItemWeight(
      min: minValue,
      max: maxValue < minValue ? minValue : maxValue,
      step: stepValue <= 0 ? minValue : stepValue,
    );
  }
}

/// Accepts both shapes the API uses for `weight`: a plain number or the
/// `{min, max, step}` range of dishes sold by weight.
MenuItemWeightModel? _weightFromJson(Object? value) {
  if (value is num) {
    return MenuItemWeightModel(min: value, max: value, step: value);
  }
  if (value is Map) {
    return MenuItemWeightModel(
      min: value['min'] is num ? value['min'] as num : null,
      max: value['max'] is num ? value['max'] as num : null,
      step: value['step'] is num ? value['step'] as num : null,
    );
  }
  if (value is String) {
    final parsed = double.tryParse(value.trim());
    return parsed == null
        ? null
        : MenuItemWeightModel(min: parsed, max: parsed, step: parsed);
  }
  return null;
}
