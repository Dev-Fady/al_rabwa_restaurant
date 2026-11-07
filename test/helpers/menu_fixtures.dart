import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

/// Categories covering the three `display_style` values.
List<MenuCategory> menuCategoriesFixture() => const [
  MenuCategory(
    id: 11,
    name: 'مشاوي علي الفحم',
    displayStyle: CategoryDisplayStyle.large,
    itemsCount: 3,
  ),
  MenuCategory(
    id: 12,
    name: 'أطباق ساخنة',
    displayStyle: CategoryDisplayStyle.list,
    itemsCount: 2,
  ),
  MenuCategory(
    id: 13,
    name: 'أطباق غربية',
    displayStyle: CategoryDisplayStyle.grid,
    itemsCount: 2,
  ),
];

const _meatItems = [
  MenuItem(id: 40, categoryId: 11, name: 'دجاج مسحب (700 غ)', price: 35),
  MenuItem(
    id: 41,
    categoryId: 11,
    name: 'دجاج مسخن',
    price: 39,
    compareAtPrice: 45,
  ),
  MenuItem(id: 44, categoryId: 11, name: 'ريش (250 غ)', price: 44),
];

const _hotItems = [
  MenuItem(id: 60, categoryId: 12, name: 'شوربة عدس', price: 15),
  MenuItem(id: 61, categoryId: 12, name: 'شوربة دجاج', price: 18),
];

const _westernItems = [
  MenuItem(id: 70, categoryId: 13, name: 'بيتزا مارغريتا', price: 30),
  MenuItem(id: 71, categoryId: 13, name: 'برجر لحم', price: 35),
];

Map<int, MenuCategoryItems> menuItemsFixture() {
  final categories = {for (final c in menuCategoriesFixture()) c.id: c};

  return {
    11: MenuCategoryItems(items: _meatItems, category: categories[11]),
    12: MenuCategoryItems(items: _hotItems, category: categories[12]),
    13: MenuCategoryItems(items: _westernItems, category: categories[13]),
  };
}

/// Payload copied from `GET /api/items/40?lang=ar`.
///
/// Pass `image: ''` for widget tests that must not request the network.
Map<String, dynamic> itemDetailsPayload({
  String? image =
      'https://al-rabwah.smartmenues.com/storage/restaurants/2/items/1742219720_1.jpg',
}) {
  return {
    'data': {
      'id': 40,
      'category_id': 11,
      'category': {'id': 11, 'name': 'مشاوي علي الفحم'},
      'name': 'دجاج مسحب (700 غ)',
      'description': null,
      'price': 35,
      'compare_at_price': null,
      'image': image,
      'video': null,
      'has_large_photo': false,
      'sold_by_weight': false,
      'weight': null,
      'options': <dynamic>[],
      'addons': <dynamic>[],
    },
  };
}

/// Payload copied from `GET /api/categories/11/items?lang=ar` (one item).
Map<String, dynamic> menuItemsPayloadWithImages() {
  return {
    'data': [
      {
        'id': 40,
        'category_id': 11,
        'name': 'دجاج مسحب (700 غ)',
        'description': null,
        'price': 35,
        'compare_at_price': null,
        'image':
            'https://al-rabwah.smartmenues.com/storage/restaurants/2/items/1742219720_1.jpg',
        'video': null,
        'has_large_photo': false,
        'sold_by_weight': false,
        'weight': null,
        'options': <dynamic>[],
        'addons': <dynamic>[],
      },
    ],
    'category': {
      'id': 11,
      'name': 'مشاوي علي الفحم',
      'image': null,
      'display_style': 'large',
      'items_count': 12,
    },
  };
}
