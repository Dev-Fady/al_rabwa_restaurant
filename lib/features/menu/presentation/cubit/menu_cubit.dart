import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'menu_state.dart';

/// Loads the menu categories and the dishes of the selected category.
///
/// Nothing is fetched until the menu tab is opened for the first time; after
/// that a language change reloads both lists.
class MenuCubit extends Cubit<MenuState> {
  MenuCubit(
    this._categoriesRepository,
    this._itemsRepository, {
    String lang = 'ar',
  }) : super(MenuState(lang: lang));

  final MenuCategoriesRepository _categoriesRepository;
  final MenuItemsRepository _itemsRepository;

  /// Loads the menu the first time the tab is opened.
  Future<void> loadIfNeeded() async {
    if (state.hasLoaded) return;
    await load();
  }

  Future<void> load({String? lang, bool refresh = false}) async {
    final targetLang = lang ?? state.lang;
    if (state.isLoadingCategories && !refresh) return;

    emit(
      state.copyWith(
        categoriesStatus: MenuStatus.loading,
        lang: targetLang,
        clearError: true,
      ),
    );

    try {
      final result = await _categoriesRepository.fetchCategories(
        lang: targetLang,
      );
      if (isClosed) return;

      await result.fold(
        (failure) async {
          if (isClosed) return;
          emit(
            state.copyWith(
              categoriesStatus: MenuStatus.failure,
              itemsStatus: MenuStatus.failure,
              items: const [],
              errorMessage: failure.message,
            ),
          );
        },
        (categories) async {
          if (isClosed) return;

          final selected = _resolveSelection(categories);
          emit(
            MenuState(
              categoriesStatus: MenuStatus.success,
              itemsStatus: selected?.id == null
                  ? MenuStatus.success
                  : MenuStatus.loading,
              categories: List.unmodifiable(categories),
              selectedCategory: selected,
              lang: targetLang,
            ),
          );

          final selectedId = selected?.id;
          if (selectedId != null) {
            await _loadItems(selectedId, lang: targetLang);
          }
        },
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          categoriesStatus: MenuStatus.failure,
          itemsStatus: MenuStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          categoriesStatus: MenuStatus.failure,
          itemsStatus: MenuStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  /// Opens [category] when it is tapped outside the menu tab (home carousel or
  /// the "all sections" page).
  Future<void> openCategory(MenuCategory category) async {
    if (!state.hasLoaded) {
      // Preselect so the very first load goes straight to the tapped section
      // instead of fetching the dishes of the default one.
      if (category.id != null) {
        emit(state.copyWith(selectedCategory: category));
      }
      await load();
    }
    if (isClosed) return;
    await selectCategory(category);
  }

  /// Opens a section by id, for entry points that only carry a `category_id`
  /// (home banners) instead of the whole category.
  Future<void> openCategoryById(int categoryId) async {
    final loaded = _categoryWithId(categoryId);
    if (loaded != null) {
      await openCategory(loaded);
      return;
    }

    if (!state.hasLoaded) {
      // The real category replaces this stub as soon as the list arrives, so
      // the first request is already the one whose dishes are wanted.
      emit(
        state.copyWith(
          selectedCategory: MenuCategory(id: categoryId, name: ''),
        ),
      );
      await load();
      if (isClosed) return;
    }

    final category = _categoryWithId(categoryId);
    if (category != null) await selectCategory(category);
  }

  Future<void> selectCategory(MenuCategory category) async {
    final categoryId = category.id;
    if (categoryId == null || categoryId == state.selectedCategory?.id) return;

    emit(
      state.copyWith(
        selectedCategory: category,
        itemsStatus: MenuStatus.loading,
        items: const [],
        clearError: true,
      ),
    );
    await _loadItems(categoryId, lang: state.lang);
  }

  Future<void> retryItems() async {
    final categoryId = state.selectedCategory?.id;
    if (categoryId == null) return;

    emit(
      state.copyWith(
        itemsStatus: MenuStatus.loading,
        items: const [],
        clearError: true,
      ),
    );
    await _loadItems(categoryId, lang: state.lang);
  }

  Future<void> refresh() => load(refresh: true);

  MenuCategory? _categoryWithId(int categoryId) {
    for (final category in state.categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  MenuCategory? _resolveSelection(List<MenuCategory> categories) {
    final selectedId = state.selectedCategory?.id;
    if (selectedId != null) {
      for (final category in categories) {
        if (category.id == selectedId) return category;
      }
    }
    return categories.isEmpty ? null : categories.first;
  }

  Future<void> _loadItems(int categoryId, {required String lang}) async {
    try {
      final result = await _itemsRepository.fetchItems(
        categoryId: categoryId,
        lang: lang,
      );
      if (isClosed) return;
      // A newer category was selected while this request was running.
      if (state.selectedCategory?.id != categoryId) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            itemsStatus: MenuStatus.failure,
            items: const [],
            errorMessage: failure.message,
          ),
        ),
        (payload) => emit(
          state.copyWith(
            itemsStatus: MenuStatus.success,
            items: List.unmodifiable(payload.items),
            selectedCategory: payload.category ?? state.selectedCategory,
            clearError: true,
          ),
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      if (state.selectedCategory?.id != categoryId) return;
      emit(
        state.copyWith(
          itemsStatus: MenuStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      if (state.selectedCategory?.id != categoryId) return;
      emit(
        state.copyWith(
          itemsStatus: MenuStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
