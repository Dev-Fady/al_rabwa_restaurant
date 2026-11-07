import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/menu_category.dart';

part 'menu_categories_response.g.dart';

/// Envelope of `GET /api/categories?lang=ar`.
///
/// ```json
/// {"data": [{"id": 11, "name": "مشاوي علي الفحم", "image": null,
///   "display_style": "large", "items_count": 12}, ...]}
/// ```
@JsonSerializable(explicitToJson: true)
class MenuCategoriesResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final List<MenuCategoryModel>? data;

  const MenuCategoriesResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory MenuCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoriesResponseToJson(this);

  List<MenuCategory> toEntities() => [
    for (final category in data ?? const <MenuCategoryModel>[])
      category.toEntity(),
  ];
}

@JsonSerializable()
class MenuCategoryModel {
  final int? id;
  final String? name;
  final String? image;

  @JsonKey(name: 'display_style')
  final String? displayStyle;

  @JsonKey(name: 'items_count')
  final int? itemsCount;

  const MenuCategoryModel({
    this.id,
    this.name,
    this.image,
    this.displayStyle,
    this.itemsCount,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuCategoryModelToJson(this);

  MenuCategory toEntity() => MenuCategory(
    id: id,
    name: name?.trim() ?? '',
    image: image?.trim() ?? '',
    displayStyle: categoryDisplayStyleFrom(displayStyle),
    itemsCount: itemsCount == null || itemsCount! < 0 ? 0 : itemsCount!,
  );
}
