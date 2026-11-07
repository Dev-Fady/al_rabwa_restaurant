import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';

import '../models/menu_items_response.dart';

/// Reads a category's dishes from `GET /api/categories/{id}/items`.
abstract class MenuItemsRemoteDataSource {
  Future<MenuItemsResponse> getCategoryItems({
    required int categoryId,
    String lang = 'ar',
  });
}

class MenuItemsRemoteDataSourceImpl implements MenuItemsRemoteDataSource {
  MenuItemsRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<MenuItemsResponse> getCategoryItems({
    required int categoryId,
    String lang = 'ar',
  }) async {
    final response = await apiService.getCategoryItems(
      categoryId: categoryId,
      lang: lang,
      xLocale: lang,
    );

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

    final parsed = MenuItemsResponse.fromJson(raw);

    // The live API omits `success`, so an explicit `false` is the only
    // reliable failure signal.
    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Failed to load items.' : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return parsed;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
