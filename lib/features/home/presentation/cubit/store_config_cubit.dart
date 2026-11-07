import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'store_config_state.dart';

/// Loads the storefront settings that drive the app's branding and home tab.
///
/// The previous settings stay in state while a refresh runs, so pull-to-refresh
/// never flashes the loading skeleton over the current content.
class StoreConfigCubit extends Cubit<StoreConfigState> {
  StoreConfigCubit(this._repository, {String lang = 'ar'})
    : super(StoreConfigState(lang: lang)) {
    load();
  }

  final SettingsRepository _repository;

  Future<void> load({String? lang, bool refresh = false}) async {
    final targetLang = lang ?? state.lang;
    if (state.isLoading && !refresh) return;

    emit(
      state.copyWith(
        status: StoreConfigStatus.loading,
        lang: targetLang,
        clearError: true,
      ),
    );

    try {
      final settings = await _repository.fetchSettings(lang: targetLang);
      if (isClosed) return;
      emit(
        StoreConfigState(
          status: StoreConfigStatus.success,
          settings: settings,
          lang: targetLang,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoreConfigStatus.failure,
          errorMessage: failure.message,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoreConfigStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() => load(refresh: true);
}
