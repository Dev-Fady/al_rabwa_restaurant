import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_categories_state.dart';

/// Loads the menu sections shown under the home hero banner.
///
/// The previously loaded categories stay in state while a refresh runs, so a
/// language switch never flashes an empty skeleton over existing content.
class HomeCategoriesCubit extends Cubit<HomeCategoriesState> {
  HomeCategoriesCubit(this._repository, {String lang = 'ar'})
    : super(HomeCategoriesState(lang: lang)) {
    load();
  }

  final MenuCategoriesRepository _repository;

  Future<void> load({String? lang, bool refresh = false}) async {
    final targetLang = lang ?? state.lang;
    if (state.isLoading && !refresh) return;

    emit(
      state.copyWith(
        status: HomeCategoriesStatus.loading,
        lang: targetLang,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.fetchCategories(lang: targetLang);
      if (isClosed) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: HomeCategoriesStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (categories) => emit(
          HomeCategoriesState(
            status: HomeCategoriesStatus.success,
            categories: List.unmodifiable(categories),
            lang: targetLang,
          ),
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeCategoriesStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeCategoriesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() => load(refresh: true);
}
