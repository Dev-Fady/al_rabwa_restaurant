import 'dart:convert';

import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_hive.dart';

/// Local storage contract for persisting customer cart lines in Hive.
abstract class CartLocalDataSource {
  Future<void> saveCart(Map<String, dynamic> json);

  Map<String, dynamic>? readCart();

  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  @override
  Future<void> saveCart(Map<String, dynamic> json) async {
    await CacheHive.saveData(
      key: AppKeys.cartData,
      value: jsonEncode(json),
    );
  }

  @override
  Map<String, dynamic>? readCart() {
    final raw = CacheHive.getDataString(key: AppKeys.cartData);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Future<void> clearCart() async {
    await CacheHive.removeData(key: AppKeys.cartData);
  }
}

