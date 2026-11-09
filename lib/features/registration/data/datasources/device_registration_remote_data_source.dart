import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';

import '../models/device_registration_response.dart';

/// Registers this device through `POST /api/device`.
abstract class DeviceRegistrationRemoteDataSource {
  Future<DeviceRegistrationResponse> registerDevice({
    required String name,
    required String phone,
    required String locale,
  });
}

class DeviceRegistrationRemoteDataSourceImpl
    implements DeviceRegistrationRemoteDataSource {
  DeviceRegistrationRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<DeviceRegistrationResponse> registerDevice({
    required String name,
    required String phone,
    required String locale,
  }) async {
    final response = await apiService.registerDevice(
      body: {'name': name, 'phone': phone, 'locale': locale},
      xLocale: locale,
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

    final parsed = DeviceRegistrationResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty
            ? 'Failed to register the device.'
            : parsed.message,
      );
    }

    if (parsed.data == null || parsed.token.trim().isEmpty) {
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
