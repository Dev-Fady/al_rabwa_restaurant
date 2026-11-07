import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'item_details_state.dart';
import 'menu_state.dart';

/// Loads one dish from `GET /api/items/{itemId}`.
class ItemDetailsCubit extends Cubit<ItemDetailsState> {
  ItemDetailsCubit(this._repository, this.itemId, {String lang = 'ar'})
    : super(ItemDetailsState(lang: lang));

  final MenuItemsRepository _repository;
  final int itemId;

  /// Fetches the dish, optionally for a new language.
  Future<void> load({String? lang}) async {
    final targetLang = lang ?? state.lang;
    if (state.isLoading && (lang == null || lang == state.lang)) return;

    emit(
      state.copyWith(
        status: MenuStatus.loading,
        lang: targetLang,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.fetchItemDetails(
        itemId: itemId,
        lang: targetLang,
      );
      if (isClosed) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: MenuStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (details) => emit(
          ItemDetailsState(
            status: MenuStatus.success,
            details: details,
            lang: targetLang,
          ),
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> retry() => load();
}
