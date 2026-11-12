import 'dart:convert';

import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_hive.dart';

/// Keeps the last successful quote per cart signature in Hive so the cart tab
/// can still show totals after a failed request or a cold start.
abstract class CartQuoteLocalDataSource {
  Future<void> save({
    required String key,
    required Map<String, dynamic> payload,
  });

  Map<String, dynamic>? read({required String key});

  Future<void> clear({required String key});
}

class CartQuoteLocalDataSourceImpl implements CartQuoteLocalDataSource {
  String _storageKey(String key) => '${AppKeys.cartQuote}_$key';

  @override
  Future<void> save({
    required String key,
    required Map<String, dynamic> payload,
  }) async {
    await CacheHive.saveData(key: _storageKey(key), value: jsonEncode(payload));
  }

  @override
  Map<String, dynamic>? read({required String key}) {
    final raw = CacheHive.getDataString(key: _storageKey(key));
    if (raw == null || raw.trim().isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  @override
  Future<void> clear({required String key}) async {
    await CacheHive.removeData(key: _storageKey(key));
  }
}
