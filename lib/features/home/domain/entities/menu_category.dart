/// A menu section returned by `GET /api/categories?lang=...`.
///
/// ```json
/// {"id": 11, "name": "مشاوي علي الفحم", "image": null,
///  "display_style": "large", "items_count": 12}
/// ```
class MenuCategory {
  const MenuCategory({
    this.id,
    this.name = '',
    this.image = '',
    this.displayStyle = CategoryDisplayStyle.list,
    this.itemsCount = 0,
  });

  final int? id;
  final String name;
  final String image;
  final CategoryDisplayStyle displayStyle;
  final int itemsCount;

  bool get hasImage => image.trim().isNotEmpty;

  /// Backend hint that this category should be rendered larger than the rest.
  bool get isLarge => displayStyle == CategoryDisplayStyle.large;

  MenuCategory copyWith({
    int? id,
    String? name,
    String? image,
    CategoryDisplayStyle? displayStyle,
    int? itemsCount,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      displayStyle: displayStyle ?? this.displayStyle,
      itemsCount: itemsCount ?? this.itemsCount,
    );
  }
}

/// `display_style` as exposed by the API.
enum CategoryDisplayStyle { large, list, grid }

/// Unknown/missing values fall back to the compact list presentation.
CategoryDisplayStyle categoryDisplayStyleFrom(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'large':
      return CategoryDisplayStyle.large;
    case 'grid':
      return CategoryDisplayStyle.grid;
    default:
      return CategoryDisplayStyle.list;
  }
}
