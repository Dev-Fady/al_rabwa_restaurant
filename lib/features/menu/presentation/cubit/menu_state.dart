import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState {
  const MenuState({
    this.categoriesStatus = MenuStatus.initial,
    this.itemsStatus = MenuStatus.initial,
    this.categories = const [],
    this.items = const [],
    this.selectedCategory,
    this.errorMessage,
    this.lang = 'ar',
  });

  final MenuStatus categoriesStatus;
  final MenuStatus itemsStatus;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final MenuCategory? selectedCategory;
  final String? errorMessage;
  final String lang;

  bool get hasLoaded => categoriesStatus != MenuStatus.initial;

  bool get isLoadingCategories => categoriesStatus == MenuStatus.loading;

  bool get isLoadingItems => itemsStatus == MenuStatus.loading;

  bool get hasCategories => categories.isNotEmpty;

  MenuState copyWith({
    MenuStatus? categoriesStatus,
    MenuStatus? itemsStatus,
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    MenuCategory? selectedCategory,
    String? errorMessage,
    String? lang,
    bool clearError = false,
  }) {
    return MenuState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      itemsStatus: itemsStatus ?? this.itemsStatus,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lang: lang ?? this.lang,
    );
  }
}
