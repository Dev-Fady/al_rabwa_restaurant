import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        const SettingsState(
          locale: Locale('ar'),
          notificationsEnabled: true,
          darkModeEnabled: false,
          // biometricsEnabled: false,
        ),
      ) {
    loadSettings();
  }

  void loadSettings() {
    try {
      final cacheHelper = getIt<CacheHelper>();

      final String? langCode = cacheHelper.getDataString(key: 'locale_code');
      final bool? notifEnabled =
          cacheHelper.getData(key: 'notifications_enabled') as bool?;
      final bool? darkEnabled =
          cacheHelper.getData(key: 'dark_mode_enabled') as bool?;
      // final bool? bioEnabled = cacheHelper.getData(key: 'biometrics_enabled') as bool?;

      emit(
        SettingsState(
          locale: Locale(langCode ?? 'ar'),
          notificationsEnabled: notifEnabled ?? true,
          darkModeEnabled: darkEnabled ?? false,
          // biometricsEnabled: bioEnabled ?? false,
        ),
      );
    } catch (_) {
      // Fallback if cache helper is not initialized yet (e.g. in tests)
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final cacheHelper = getIt<CacheHelper>();
      await cacheHelper.saveData(key: 'locale_code', value: languageCode);
    } catch (_) {}
    if (isClosed) return;
    emit(state.copyWith(locale: Locale(languageCode)));
  }

  Future<void> toggleNotifications(bool value) async {
    try {
      final cacheHelper = getIt<CacheHelper>();
      await cacheHelper.saveData(key: 'notifications_enabled', value: value);
    } catch (_) {}
    if (isClosed) return;
    emit(state.copyWith(notificationsEnabled: value));
  }

  Future<void> toggleDarkMode(bool value) async {
    try {
      final cacheHelper = getIt<CacheHelper>();
      await cacheHelper.saveData(key: 'dark_mode_enabled', value: value);
    } catch (_) {}
    if (isClosed) return;
    emit(state.copyWith(darkModeEnabled: value));
  }

  // Future<void> toggleBiometrics(bool value) async {
  //   try {
  //     final cacheHelper = getIt<CacheHelper>();
  //     await cacheHelper.saveData(key: 'biometrics_enabled', value: value);
  //   } catch (_) {}
  //   emit(state.copyWith(biometricsEnabled: value));
  // }
}
