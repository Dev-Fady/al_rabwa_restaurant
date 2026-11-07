import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';

import '../models/restaurant_settings_response.dart';

/// Reads the storefront settings payload from `GET /api/settings`.
abstract class SettingsRemoteDataSource {
  Future<SettingsPayload> getSettings({String lang = 'ar'});
}

/// Parsed response plus the raw JSON map, which is what gets cached.
class SettingsPayload {
  const SettingsPayload({required this.response, required this.raw});

  final RestaurantSettingsResponse response;
  final Map<String, dynamic> raw;
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<SettingsPayload> getSettings({String lang = 'ar'}) async {
    final response = await apiService.getSettings(lang: lang, xLocale: lang);

    final body = response.data;
    final Map<String, dynamic>? raw;
    if (body is Map<String, dynamic>) {
      raw = body;
    } else if (body is Map) {
      raw = Map<String, dynamic>.from(body);
    } else if (body is String && body.trim().isNotEmpty) {
      raw = _asMap(jsonDecode(body));
    } else {
      raw = null;
    }

    if (raw == null) {
      throw ServerFailure('Empty response from server.');
    }

    final parsed = RestaurantSettingsResponse.fromJson(raw);

    // The live API omits `success`, so an explicit `false` is the only
    // reliable failure signal. A missing flag falls through to the data check.
    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Failed to load settings.' : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return SettingsPayload(response: parsed, raw: raw);
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
