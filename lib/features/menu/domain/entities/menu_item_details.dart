import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';

import 'menu_item.dart';

/// A dish plus the category summary returned by
/// `GET /api/items/{id}?lang=...`.
class MenuItemDetails {
  const MenuItemDetails({required this.item, this.category});

  final MenuItem item;
  final MenuCategory? category;
}
