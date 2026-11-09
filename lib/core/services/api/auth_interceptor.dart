import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';
import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

/// Adds the bearer token and backend locale to requests, prevents unauthenticated
/// calls to protected endpoints by redirecting to device registration, and
/// handles 401 Unauthorized responses.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;

  static const String requiresTokenExtra = 'requiresToken';
  static const String requiresTokenHeader = 'requires-token';

  static bool _isNavigatingToRegistration = false;

  AuthInterceptor({required this.storage, required this.dio});

  @visibleForTesting
  static void resetNavigationFlag() {
    _isNavigatingToRegistration = false;
  }

  /// Whether the request target requires an authentication Bearer token.
  bool requiresBearerToken(RequestOptions options) {
    if (options.extra[requiresTokenExtra] == true) return true;
    final headerValue = options.headers[requiresTokenHeader];
    if (headerValue == 'true' || headerValue == true) return true;

    final path = options.path;
    // Registration endpoint never requires a token.
    if (path.contains(ApiConstants.device)) return false;

    // Public storefront endpoints never require a token.
    if (path.contains(ApiConstants.settings) ||
        path.contains(ApiConstants.categories) ||
        path.contains('items')) {
      return false;
    }

    // Default known protected endpoints.
    if (path.contains(ApiConstants.addresses) ||
        path.contains(ApiConstants.orders) ||
        path.contains(ApiConstants.user) ||
        path.contains(ApiConstants.deleteAccount) ||
        path.contains(ApiConstants.logout)) {
      return true;
    }

    return false;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresToken = requiresBearerToken(options);
    options.headers.remove(requiresTokenHeader);

    // Secure storage can throw on web (e.g. Safari private mode with
    // storage blocked). A token read failure must never crash the app.
    String? accessToken;
    try {
      accessToken = await storage.read(key: AppKeys.accessToken);
    } catch (_) {
      accessToken = null;
    }

    final hasToken = accessToken != null && accessToken.trim().isNotEmpty;

    // If the endpoint requires authentication but no token exists,
    // intercept the call, prompt device registration, and reject.
    if (requiresToken && !hasToken) {
      _goToRegistration();
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            statusMessage: 'Unauthorized: Device registration required',
          ),
          type: DioExceptionType.badResponse,
          error: 'Unauthorized: Device registration required',
        ),
      );
      return;
    }

    if (hasToken) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Backend locale follows the app language. Keep any explicit
    // `x-locale` (per-call override), otherwise use the saved app
    // locale (`locale_code` via SettingsCubit) and fall back to 'ar'.
    final existingLocale = options.headers['x-locale'];
    if (existingLocale == null ||
        (existingLocale is String && existingLocale.trim().isEmpty)) {
      options.headers['x-locale'] = _resolveLocale();
    }

    handler.next(options);
  }

  String _resolveLocale() {
    try {
      final stored = CacheHelper.sharedPreferences.getString('locale_code');
      if (stored != null && stored.trim().isNotEmpty) {
        return stored.trim();
      }
    } catch (_) {
      // SharedPreferences may be unavailable in tests/web private mode.
    }
    return 'ar';
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    handler.next(err);

    if (err.response?.statusCode != 401) return;

    await AuthHelper.clearSession(storage);
    _goToRegistration();
  }

  /// Sends the user to the device registration screen, once a navigator exists.
  void _goToRegistration() {
    final navigatorKey = AppRouter.rootNavigatorKey;
    if (navigatorKey.currentContext == null) return;
    if (_isNavigatingToRegistration) return;
    _isNavigatingToRegistration = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) {
        _isNavigatingToRegistration = false;
        return;
      }

      try {
        final currentRoute = GoRouterState.of(context).uri.toString();
        if (currentRoute == AppRoutes.registration) {
          _isNavigatingToRegistration = false;
          return;
        }
      } catch (_) {}

      try {
        AppRouter.router.push(AppRoutes.registration).then((_) {
          _isNavigatingToRegistration = false;
        }).catchError((_) {
          _isNavigatingToRegistration = false;
        });
      } catch (_) {
        _isNavigatingToRegistration = false;
      }
    });
  }
}
