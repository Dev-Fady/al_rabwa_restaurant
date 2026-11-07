import 'package:dio/dio.dart';

/// Retries transient network failures on idempotent requests.
///
/// The API is served cross-origin and sits behind an edge that intermittently
/// drops the TCP/TLS connection. When that happens the browser never reaches
/// the backend and Dio reports `DioExceptionType.connectionError`, so the app
/// shows "no internet" even though a fresh connection usually succeeds. A
/// short, bounded retry turns most of those spurious failures into a
/// successful response.
///
/// Only `GET`/`HEAD` are retried (plus gateway timeouts): replaying a write
/// could duplicate a side effect such as a second cart line or order.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
  }) : assert(maxAttempts >= 1, 'maxAttempts must allow at least one try');

  /// Used to replay the failed [RequestOptions] through a fresh connection.
  final Dio dio;

  /// Total tries per request: the first attempt plus [maxAttempts] - 1 retries.
  final int maxAttempts;

  /// Delay before the first retry; it doubles for every following retry.
  final Duration baseDelay;

  /// Bookkeeping key kept on [RequestOptions.extra] so a replayed request
  /// knows which attempt it is on.
  static const String attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = _attemptOf(options);

    if (!_isRetryable(err) || attempt >= maxAttempts) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(baseDelay * _multiplier(attempt));
    options.extra[attemptKey] = attempt + 1;

    try {
      // `fetch` runs the whole interceptor chain again on a new connection,
      // so the retry also picks up a fresh auth header / locale.
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      // The replayed request failed too; its own error already went through
      // this interceptor, so surface the final error.
      handler.next(retryError);
    }
  }

  static int _attemptOf(RequestOptions options) {
    final attempt = options.extra[attemptKey];
    return attempt is int && attempt > 0 ? attempt : 1;
  }

  static int _multiplier(int attempt) => 1 << (attempt - 1);

  bool _isRetryable(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    final isIdempotent = method == 'GET' || method == 'HEAD';
    if (!isIdempotent) return false;

    switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        return statusCode == 502 || statusCode == 503 || statusCode == 504;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return false;
    }
  }
}
