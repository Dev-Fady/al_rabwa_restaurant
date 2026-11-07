import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/home/data/models/restaurant_settings_response.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:dio/dio.dart';

/// Fetches the storefront settings and keeps the last successful payload in
/// local storage, so a cold start without network still renders the menu's
/// branding instead of an error screen.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._apiService, [this._cacheHelper]);

  final ApiService _apiService;
  final CacheHelper? _cacheHelper;

  static const String _cacheKeyPrefix = 'restaurant_settings_';

  @override
  Future<RestaurantSettings> fetchSettings({String lang = 'ar'}) async {
    try {
      final response = await _apiService.getSettings(lang: lang, xLocale: lang);
      final raw = _asMap(response.data);
      final parsed = raw == null
          ? null
          : RestaurantSettingsResponse.fromJson(raw);
      final settings = parsed?.toEntity();

      if (settings == null) {
        throw const FormatException('Empty settings payload');
      }

      await _saveToCache(lang, raw!);
      return settings;
    } on DioException catch (error) {
      final cached = await _readFromCache(lang);
      if (cached != null) return cached;
      throw ServerFailure.fromDioException(error);
    } on Failure {
      rethrow;
    } catch (error) {
      final cached = await _readFromCache(lang);
      if (cached != null) return cached;
      throw ServerFailure.fromError(error);
    }
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      return _asMap(decoded);
    }
    return null;
  }

  String _cacheKey(String lang) => '$_cacheKeyPrefix$lang';

  Future<void> _saveToCache(String lang, Map<String, dynamic> raw) async {
    final cache = _cacheHelper;
    if (cache == null) return;
    try {
      await cache.saveData(key: _cacheKey(lang), value: jsonEncode(raw));
    } catch (_) {
      // Caching is best-effort; the fresh response is already in hand.
    }
  }

  Future<RestaurantSettings?> _readFromCache(String lang) async {
    final cache = _cacheHelper;
    if (cache == null) return null;
    try {
      final raw = cache.getDataString(key: _cacheKey(lang));
      if (raw == null || raw.trim().isEmpty) return null;
      final decoded = _asMap(raw);
      if (decoded == null) return null;
      return RestaurantSettingsResponse.fromJson(decoded).toEntity();
    } catch (_) {
      return null;
    }
  }
}
