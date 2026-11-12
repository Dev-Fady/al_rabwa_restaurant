import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/tables/data/models/table_response.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';

/// Reads the dine-in tables through `GET /api/tables`.
abstract class TablesRemoteDataSource {
  Future<List<DiningTable>> fetchTables({String lang = 'ar'});
}

class TablesRemoteDataSourceImpl implements TablesRemoteDataSource {
  TablesRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<DiningTable>> fetchTables({String lang = 'ar'}) async {
    final response = await apiService.getTables(lang: lang, xLocale: lang);

    final raw = _decodeBody(response.data);
    final parsed = TableListResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Failed to load the tables.' : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return parsed.toEntities();
  }

  Map<String, dynamic> _decodeBody(dynamic body) {
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

    return raw;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
