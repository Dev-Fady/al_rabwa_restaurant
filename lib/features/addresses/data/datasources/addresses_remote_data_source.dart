import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';

import '../models/address_response.dart';

/// Reads and creates delivery addresses through `/api/addresses`.
abstract class AddressesRemoteDataSource {
  Future<List<Address>> fetchAddresses({String lang = 'ar'});

  Future<AddressResponse> fetchAddress({required int id, String lang = 'ar'});

  Future<AddressResponse> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  });

  Future<AddressResponse> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  });

  Future<AddressResponse> setDefaultAddress({
    required int id,
    String lang = 'ar',
  });
}

class AddressesRemoteDataSourceImpl implements AddressesRemoteDataSource {
  AddressesRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<List<Address>> fetchAddresses({String lang = 'ar'}) async {
    final response = await apiService.getAddresses(lang: lang, xLocale: lang);

    final raw = _decodeBody(response.data);
    final parsed = AddressListResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty
            ? 'Failed to load the saved addresses.'
            : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return parsed.toEntities();
  }

  @override
  Future<AddressResponse> fetchAddress({
    required int id,
    String lang = 'ar',
  }) async {
    final response = await apiService.getAddress(
      id: id,
      lang: lang,
      xLocale: lang,
    );

    return _parseResponse(
      response.data,
      failureMessage: 'Failed to load the address.',
    );
  }

  @override
  Future<AddressResponse> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    final response = await apiService.createAddress(
      body: _body(
        kind: kind,
        label: label,
        area: area,
        street: street,
        building: building,
        notes: notes,
        point: point,
      ),
      lang: lang,
      xLocale: lang,
    );

    return _parseResponse(
      response.data,
      failureMessage: 'Failed to save the address.',
    );
  }

  @override
  Future<AddressResponse> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    final response = await apiService.updateAddress(
      id: id,
      body: _body(
        kind: kind,
        label: label,
        area: area,
        street: street,
        building: building,
        notes: notes,
        point: point,
      ),
      lang: lang,
      xLocale: lang,
    );

    return _parseResponse(
      response.data,
      failureMessage: 'Failed to update the address.',
    );
  }

  @override
  Future<AddressResponse> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) async {
    final response = await apiService.setDefaultAddress(
      id: id,
      lang: lang,
      xLocale: lang,
    );

    return _parseResponse(
      response.data,
      failureMessage: 'Failed to set the default address.',
    );
  }

  Map<String, dynamic> _body({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
  }) {
    return {
      'kind': kind.apiValue,
      'label': _optional(label),
      'area': area.trim(),
      'street': street.trim(),
      'building': _optional(building),
      'notes': _optional(notes),
      // The backend stores a double; six decimals is about 10 cm of
      // precision, far beyond what the map picker can express.
      'latitude': _round(point.latitude),
      'longitude': _round(point.longitude),
    };
  }

  AddressResponse _parseResponse(
    dynamic body, {
    required String failureMessage,
  }) {
    final raw = _decodeBody(body);
    final parsed = AddressResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty ? failureMessage : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return parsed;
  }

  /// Optional fields are sent as `null` rather than `''` so the backend can
  /// fall back to its own defaults (e.g. the title from the kind label).
  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double _round(double value) => double.parse(value.toStringAsFixed(6));

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
