import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the two halves of the local session consistent.
///
/// A session is split across stores with different lifetimes:
///
/// * `is_login` lives in `SharedPreferences` (Android `shared_prefs`, Windows
///   registry), which **is** part of Android Auto Backup.
/// * the bearer token lives in secure storage, whose encryption key sits in
///   the platform keystore/keychain and is **never** backed up or restored.
///
/// After a reinstall or a backup restore the flag can therefore come back
/// alone: the app then opens Home while every protected call is sent without
/// a valid token and fails with 401 "Unauthorized".
///
/// [reconcileSession] runs once before `runApp`; [clearSession] is shared by
/// the 401 interceptor and the profile logout flow.
class AuthHelper {
  AuthHelper._();

  /// The stored `is_login` flag. Never throws: without storage (early
  /// startup, widget tests, web private mode) the session counts as absent.
  static bool get hasLoginFlag {
    try {
      return CacheHelper.sharedPreferences.getBool(AppKeys.isLogin) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether a non-empty access token is stored on this device.
  ///
  /// Never throws: without storage (early startup, widget tests, web private
  /// mode) the device simply counts as not registered yet.
  static Future<bool> hasSavedToken(FlutterSecureStorage storage) async {
    try {
      final token = await storage.read(key: AppKeys.accessToken);
      return token != null && token.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Persists a freshly issued device token and marks the session as signed in.
  ///
  /// The token write is allowed to throw so the caller can report that the
  /// session could not be stored. The flags are best-effort and never block a
  /// successful registration.
  static Future<void> saveSession(
    FlutterSecureStorage storage, {
    required String token,
  }) async {
    await storage.write(key: AppKeys.accessToken, value: token);
    try {
      await CacheHelper.sharedPreferences.setBool(AppKeys.isLogin, true);
      await CacheHelper.sharedPreferences.remove(AppKeys.isGuest);
    } catch (_) {
      // Storage failure must not invalidate the token that was just saved.
    }
  }

  /// Drops `is_login` when its bearer token is missing, empty or unreadable,
  /// so the router sends the user to the login screen instead of Home.
  ///
  /// Guests (`is_guest`) are intentionally left alone: browsing without any
  /// token is exactly what guest mode is. Never throws — routing must always
  /// be able to proceed.
  static Future<void> reconcileSession(FlutterSecureStorage storage) async {
    if (!hasLoginFlag) return;

    String? token;
    try {
      token = await storage.read(key: AppKeys.accessToken);
    } catch (_) {
      // Unreadable storage (keystore key gone after reinstall, tests, web
      // private mode): the interceptor could not attach a token either, so
      // this session can never succeed.
      token = null;
    }
    if (token != null && token.isNotEmpty) return;

    try {
      await CacheHelper.sharedPreferences.setBool(AppKeys.isLogin, false);
    } catch (_) {
      // Storage failure must never block startup; a later 401 still clears it.
    }
  }

  /// Wipes the signed-in session: tokens plus both local flags.
  ///
  /// Each store is cleared independently and nothing is thrown, so a failure
  /// in one leaves the others (already handled) intact.
  static Future<void> clearSession(FlutterSecureStorage storage) async {
    try {
      await storage.delete(key: AppKeys.accessToken);
      await storage.delete(key: AppKeys.refreshToken);
    } catch (_) {
      // Ignore (e.g. web private mode). The flags below still invalidate it.
    }
    try {
      await CacheHelper.sharedPreferences.remove(AppKeys.isLogin);
      await CacheHelper.sharedPreferences.remove(AppKeys.isGuest);
    } catch (_) {
      // Ignore: hasLoginFlag already returns false when storage is missing.
    }
  }
}
