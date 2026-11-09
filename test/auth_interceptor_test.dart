import 'dart:typed_data';

import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';
import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/services/api/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage({Map<String, String>? initial}) {
    if (initial != null) values.addAll(initial);
  }

  final Map<String, String> values = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

class _CaptureAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;
  int statusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    if (statusCode == 401) {
      throw DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          statusMessage: 'Unauthorized',
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return ResponseBody.fromString('{"ok":true}', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

Dio _createDio(FlutterSecureStorage storage, _CaptureAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(AuthInterceptor(storage: storage, dio: dio));
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AuthInterceptor.resetNavigationFlag();
  });

  group('AuthInterceptor', () {
    test('allows public endpoint without token and does not inject auth header', () async {
      final storage = _FakeSecureStorage();
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      final response = await dio.get<dynamic>(ApiConstants.settings);

      expect(response.statusCode, 200);
      expect(adapter.lastOptions, isNotNull);
      expect(adapter.lastOptions!.headers['Authorization'], isNull);
    });

    test('attaches Bearer token to request when token exists', () async {
      final storage = _FakeSecureStorage(initial: {
        AppKeys.accessToken: 'mock_token_123',
      });
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      final response = await dio.get<dynamic>(ApiConstants.settings);

      expect(response.statusCode, 200);
      expect(adapter.lastOptions, isNotNull);
      expect(
        adapter.lastOptions!.headers['Authorization'],
        'Bearer mock_token_123',
      );
    });

    test('rejects protected endpoint when token is missing', () async {
      final storage = _FakeSecureStorage();
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      expect(
        () => dio.post<dynamic>(ApiConstants.addresses, data: {'label': 'Home'}),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      // Ensure request was intercepted before adapter was called
      expect(adapter.lastOptions, isNull);
    });

    test('allows protected endpoint when token is present', () async {
      final storage = _FakeSecureStorage(initial: {
        AppKeys.accessToken: 'saved_device_token',
      });
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      final response = await dio.post<dynamic>(
        ApiConstants.addresses,
        data: {'label': 'Home'},
      );

      expect(response.statusCode, 200);
      expect(adapter.lastOptions, isNotNull);
      expect(
        adapter.lastOptions!.headers['Authorization'],
        'Bearer saved_device_token',
      );
    });

    test('rejects request with requiresToken extra when token is missing', () async {
      final storage = _FakeSecureStorage();
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      expect(
        () => dio.get<dynamic>(
          'custom-endpoint',
          options: Options(extra: {'requiresToken': true}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(adapter.lastOptions, isNull);
    });

    test('removes internal requires-token header before sending request', () async {
      final storage = _FakeSecureStorage(initial: {
        AppKeys.accessToken: 'token',
      });
      final adapter = _CaptureAdapter();
      final dio = _createDio(storage, adapter);

      await dio.get<dynamic>(
        'test',
        options: Options(headers: {'requires-token': 'true'}),
      );

      expect(adapter.lastOptions, isNotNull);
      expect(adapter.lastOptions!.headers['requires-token'], isNull);
    });

    test('clears session on 401 response from backend', () async {
      final storage = _FakeSecureStorage(initial: {
        AppKeys.accessToken: 'expired_token',
      });
      final adapter = _CaptureAdapter()..statusCode = 401;
      final dio = _createDio(storage, adapter);

      expect(
        () => dio.get<dynamic>(ApiConstants.settings),
        throwsA(isA<DioException>()),
      );

      // Verify token was cleared from secure storage
      expect(storage.values[AppKeys.accessToken], isNull);
    });
  });
}

