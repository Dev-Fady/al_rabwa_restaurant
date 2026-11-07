import 'dart:convert';

import 'package:al_rabwa_restaurant/core/helper_functions/cache_hive.dart';

/// Keeps the last successful settings payload per language in Hive so the
/// storefront can still render after a cold start without network.
abstract class SettingsLocalDataSource {
  Future<void> save({
    required String lang,
    required Map<String, dynamic> payload,
  });

  Map<String, dynamic>? read({required String lang});

  Future<void> clear({required String lang});
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _keyPrefix = 'restaurant_settings_';

  String _key(String lang) => '$_keyPrefix$lang';

  @override
  Future<void> save({
    required String lang,
    required Map<String, dynamic> payload,
  }) async {
    await CacheHive.saveData(key: _key(lang), value: jsonEncode(payload));
  }

  @override
  Map<String, dynamic>? read({required String lang}) {
    final raw = CacheHive.getDataString(key: _key(lang));
    if (raw == null || raw.trim().isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  @override
  Future<void> clear({required String lang}) async {
    await CacheHive.removeData(key: _key(lang));
  }
}
