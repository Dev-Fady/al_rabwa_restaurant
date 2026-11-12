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
    this.weightRange,
    this.options = const [],
    this.addons = const [],
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

  /// Selectable weight for dishes sold by weight; `null` otherwise.
  final MenuItemWeight? weightRange;

  /// Portion choices, e.g. "نفر واحد" / "نفرين"; one may be selected.
  final List<MenuItemOption> options;

  /// Extras the customer can add to the dish; any number may be selected.
  final List<MenuItemAddon> addons;

  bool get hasImage => image.trim().isNotEmpty;

  bool get hasVideo => video.trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  bool get hasOptions => options.isNotEmpty;

  bool get hasAddons => addons.isNotEmpty;

  bool get hasWeightRange => soldByWeight && (weightRange?.hasRange ?? false);

  bool get hasDiscount => compareAtPrice != null && compareAtPrice! > price;

  /// Portion used by quick-add buttons when the details page is not opened.
  MenuItemOption? get defaultOption => options.isEmpty ? null : options.first;

  /// Starting weight used by quick-add; `1` for dishes not sold by weight.
  double get defaultWeight => soldByWeight ? (weight ?? 1) : 1;

  /// Starting weight, kept for callers that only need one value.
  double? get weight => weightRange?.min;
}

/// One portion choice of a dish, e.g. `{"id": 8, "name": "نفرين", "price": 30}`.
class MenuItemOption {
  const MenuItemOption({this.id, this.name = '', this.price = 0});

  final int? id;
  final String name;
  final double price;

  bool get hasPrice => price != 0;
}

/// An extra added to a dish, e.g. `{"id": 34, "name": "إضافة أرز", "price": 5}`.
class MenuItemAddon {
  const MenuItemAddon({
    this.id,
    this.name = '',
    this.price = 0,
    this.image = '',
  });

  final int? id;
  final String name;
  final double price;
  final String image;

  bool get hasPrice => price != 0;
}

/// Range the customer picks the dish's weight from, e.g.
/// `{"min": 0.25, "max": 10, "step": 0.25}` for meat sold by the kilo.
class MenuItemWeight {
  const MenuItemWeight({
    required this.min,
    required this.max,
    required this.step,
  });

  final double min;
  final double max;
  final double step;

  /// A single selectable value is not a range.
  bool get hasRange => max > min && step > 0;

  /// Every weight the customer can choose, starting at [min].
  List<double> get choices {
    if (!hasRange) return [min];
    final count = ((max - min) / step).floor() + 1;
    return [for (var index = 0; index < count; index++) min + step * index];
  }
}
