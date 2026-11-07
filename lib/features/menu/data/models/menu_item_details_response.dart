import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/menu_item_details.dart';
import 'menu_items_response.dart';

part 'menu_item_details_response.g.dart';

/// Envelope of `GET /api/items/{id}?lang=ar`.
///
/// ```json
/// {"data": {"id": 40, "category_id": 11,
///   "category": {"id": 11, "name": "مشاوي علي الفحم"},
///   "name": "دجاج مسحب (700 غ)", "price": 35, ...}}
/// ```
@JsonSerializable(explicitToJson: true)
class MenuItemDetailsResponse {
  @JsonKey(defaultValue: false)
  final bool success;

  @JsonKey(defaultValue: '')
  final String message;

  final MenuItemModel? data;

  const MenuItemDetailsResponse({
    this.success = false,
    this.message = '',
    this.data,
  });

  factory MenuItemDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemDetailsResponseToJson(this);

  /// `null` when the payload has no dish.
  MenuItemDetails? toEntity() {
    final model = data;
    if (model == null) return null;

    return MenuItemDetails(
      item: model.toEntity(),
      category: model.category?.toEntity(),
    );
  }
}
