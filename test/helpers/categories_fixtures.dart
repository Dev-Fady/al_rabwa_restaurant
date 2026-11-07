import 'package:al_rabwa_restaurant/features/home/data/models/menu_categories_response.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';

/// Payload copied from `GET /api/categories?lang=ar`.
Map<String, dynamic> categoriesPayload() {
  return {
    'data': [
      {
        'id': 11,
        'name': 'مشاوي علي الفحم',
        'image': null,
        'display_style': 'large',
        'items_count': 12,
      },
      {
        'id': 12,
        'name': 'أطباق ساخنة',
        'image': null,
        'display_style': 'list',
        'items_count': 29,
      },
      {
        'id': 13,
        'name': 'أطباق غربية',
        'image': null,
        'display_style': 'list',
        'items_count': 12,
      },
      {
        'id': 14,
        'name': 'أطباق بحرية',
        'image': null,
        'display_style': 'list',
        'items_count': 17,
      },
      {
        'id': 15,
        'name': 'السندويشات',
        'image': null,
        'display_style': 'list',
        'items_count': 16,
      },
      {
        'id': 16,
        'name': 'الفطائر',
        'image': null,
        'display_style': 'list',
        'items_count': 15,
      },
      {
        'id': 17,
        'name': 'المقبلات الساخنة',
        'image': null,
        'display_style': 'list',
        'items_count': 22,
      },
      {
        'id': 18,
        'name': 'المقبلات الباردة',
        'image': null,
        'display_style': 'list',
        'items_count': 13,
      },
      {
        'id': 19,
        'name': 'الباستا',
        'image': null,
        'display_style': 'list',
        'items_count': 11,
      },
      {
        'id': 20,
        'name': 'الشوربات',
        'image': null,
        'display_style': 'list',
        'items_count': 9,
      },
      {
        'id': 21,
        'name': 'السلطات',
        'image': null,
        'display_style': 'list',
        'items_count': 21,
      },
      {
        'id': 22,
        'name': 'الحلويات',
        'image': null,
        'display_style': 'list',
        'items_count': 7,
      },
      {
        'id': 23,
        'name': 'العصائر والمشروبات',
        'image': null,
        'display_style': 'list',
        'items_count': 15,
      },
    ],
  };
}

List<MenuCategory> sampleCategories() {
  return MenuCategoriesResponse.fromJson(categoriesPayload()).toEntities();
}
