import 'dart:typed_data';

import 'package:al_rabwa_restaurant/core/services/api/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plays back a scripted sequence of outcomes: a [DioExceptionType] to throw,
/// or `null` for a successful 200 response. The last entry repeats once the
/// script runs out.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<DioExceptionType?> script;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final failure = script[calls < script.length ? calls : script.length - 1];
    calls++;

    if (failure != null) {
      throw DioException(requestOptions: options, type: failure);
    }
    return ResponseBody.fromString('{"ok":true}', 200);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'));
  dio.httpClientAdapter = adapter;
  // No delay keeps the retry assertions deterministic and fast.
  dio.interceptors.add(RetryInterceptor(dio: dio, baseDelay: Duration.zero));
  return dio;
}

void main() {
  test('retries a POST when the connection was never established', () async {
    final adapter = _ScriptedAdapter([
      DioExceptionType.connectionTimeout,
      null,
    ]);

    final response = await _dioWith(adapter).post<dynamic>('/orders');

    expect(response.statusCode, 200);
    expect(adapter.calls, 2);
  });

  test('does not replay a POST after the connection was established', () async {
    final adapter = _ScriptedAdapter([DioExceptionType.receiveTimeout]);

    await expectLater(
      _dioWith(adapter).post<dynamic>('/orders'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
    expect(adapter.calls, 1);
  });

  test('retries a GET on a dropped connection', () async {
    final adapter = _ScriptedAdapter([DioExceptionType.connectionError, null]);

    final response = await _dioWith(adapter).get<dynamic>('/settings');

    expect(response.statusCode, 200);
    expect(adapter.calls, 2);
  });

  test('surfaces the failure after the attempt budget is spent', () async {
    final adapter = _ScriptedAdapter([DioExceptionType.connectionTimeout]);

    await expectLater(
      _dioWith(adapter).post<dynamic>('/orders'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 3);
  });
}
