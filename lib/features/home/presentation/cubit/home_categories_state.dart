import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';

enum HomeCategoriesStatus { initial, loading, success, failure }

class HomeCategoriesState {
  const HomeCategoriesState({
    this.status = HomeCategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.lang = 'ar',
  });

  final HomeCategoriesStatus status;
  final List<MenuCategory> categories;
  final String? errorMessage;
  final String lang;

  bool get isLoading => status == HomeCategoriesStatus.loading;

  bool get hasCategories => categories.isNotEmpty;

  HomeCategoriesState copyWith({
    HomeCategoriesStatus? status,
    List<MenuCategory>? categories,
    String? errorMessage,
    String? lang,
    bool clearError = false,
  }) {
    return HomeCategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lang: lang ?? this.lang,
    );
  }
}
