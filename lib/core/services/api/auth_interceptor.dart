import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Adds the bearer token and the backend locale to every request, and
/// invalidates the local session when the backend answers 401.
///
/// This is a plain [Interceptor], not a [QueuedInterceptor]: nothing here
/// depends on the previous request finishing (there is no token refresh), and
/// the queue would run `onRequest` — including its `await`ed secure-storage
/// read — strictly one request at a time, delaying every parallel screen load
/// (the home tab alone fires several reads at once).
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;

  AuthInterceptor({required this.storage, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Secure storage can throw on web (e.g. Safari private mode with
    // storage blocked). A token read failure must never fail the request.
    String? accessToken;
    try {
      accessToken = await storage.read(key: AppKeys.accessToken);
    } catch (_) {
      accessToken = null;
    }

    if (accessToken != null && accessToken.isNotEmpty) {
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
      // CacheHelper stores the app language under `locale_code`
      // (see SettingsCubit). Read directly to avoid adding a new
      // dependency to this interceptor.
      final stored = CacheHelper.sharedPreferences.getString('locale_code');
      if (stored != null && stored.trim().isNotEmpty) {
        return stored.trim();
      }
    } catch (_) {
      // SharedPreferences may be unavailable in tests/web private mode.
    }
    return 'ar';
  }

  /// The backend rejected the bearer token we sent (expired, revoked, or a
  /// leftover from an install that kept the local flags but lost the keystore
  /// key). The caller still gets the error so the screen can show it, while
  /// the local session is invalidated and the user is taken to the login
  /// screen instead of every following call failing the same way.
  ///
  /// Only signed-in sessions are handled: guests browse without a token by
  /// design, and a signed-out user must never be bounced from an auth screen.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Propagate first: the failing screen must never wait on local storage.
    handler.next(err);

    if (err.response?.statusCode != 401) return;
    if (!AuthHelper.hasLoginFlag) return;

    await AuthHelper.clearSession(storage);
    _goToLogin();
  }

  /// Sends the user to the login screen, once a navigator exists.
  ///
  /// Navigation is deferred to the end of the frame: interceptors run outside
  /// the build phase but can overlap one, and several parallel 401s may
  /// schedule it together (repeating `go` on the same location is a no-op).
  void _goToLogin() {
    final navigatorKey = AppRouter.rootNavigatorKey;
    // No navigator yet (cold start before the first frame, or a unit test):
    // the session is already cleared, so the next launch lands on login.
    if (navigatorKey.currentContext == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext == null) return;
      AppRouter.router.go(AppRoutes.login);
    });
  }
}
