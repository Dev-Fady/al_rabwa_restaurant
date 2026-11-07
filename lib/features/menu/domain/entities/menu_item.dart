/// A single dish returned by `GET /api/categories/{id}/items`.
///
/// ```json
/// {"id": 40, "category_id": 11, "name": "دجاج مسحب (700 غ)",
///  "description": null, "price": 35, "compare_at_price": null,
///  "image": "https://.../items/1742219720_1.jpg", "video": null,
///  "has_large_photo": false, "sold_by_weight": false, "weight": null,
///  "options": [], "addons": []}
/// ```
class MenuItem {
  const MenuItem({
    this.id,
    this.categoryId,
    this.name = '',
    this.description = '',
    this.price = 0,
    this.compareAtPrice,
    this.image = '',
    this.video = '',
    this.hasLargePhoto = false,
    this.soldByWeight = false,
    this.weight,
    this.hasOptions = false,
    this.hasAddons = false,
  });

  final int? id;
  final int? categoryId;
  final String name;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String image;
  final String video;
  final bool hasLargePhoto;
  final bool soldByWeight;
  final double? weight;
  final bool hasOptions;
  final bool hasAddons;

  bool get hasImage => image.trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;
}
