import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';
import 'package:al_rabwa_restaurant/core/services/api/auth_interceptor.dart';
import 'package:al_rabwa_restaurant/core/services/api/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioConfig {
  static Dio createDio(FlutterSecureStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // Keep failures fast. On web Dio sets the XHR deadline to
        // `connectTimeout + receiveTimeout`, so these two bound a stuck call
        // at ~30s instead of the previous 60s.
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        // No `sendTimeout`: it only applies to requests with a body and, on
        // web, forces an upload-progress listener that turns the request into
        // a CORS preflight. The request bodies here are tiny multipart forms.
        headers: {
          'Accept': 'application/json',
          // Do NOT set a global `Content-Type`. GET requests must stay
          // bodyless/simple; Retrofit already sets `multipart/form-data` on
          // the POST endpoints (see api_service.g.dart).
          //
          // `x-locale` is injected per request by AuthInterceptor from the
          // saved app locale (`locale_code`, default 'ar').
        },
      ),
    );

    // Auth first so retried requests also carry a fresh token and locale.
    dio.interceptors.add(AuthInterceptor(storage: storage, dio: dio));
    dio.interceptors.add(RetryInterceptor(dio: dio));

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
        ),
      );
    }

    return dio;
  }
}
