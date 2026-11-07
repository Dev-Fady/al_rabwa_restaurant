import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';

import 'menu_item.dart';

/// Dishes of one category plus the category summary echoed by the endpoint.
class MenuCategoryItems {
  const MenuCategoryItems({this.items = const [], this.category});

  final List<MenuItem> items;
  final MenuCategory? category;
}
