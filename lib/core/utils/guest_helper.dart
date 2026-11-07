
import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';

/// Local guest mode: user browses the app without an auth token.
/// Guests can view public content (home/videos) but must login
/// for bookings, recordings and profile data.
class GuestHelper {
  GuestHelper._();

  static bool isGuestMode() {
    final isLogin =
        CacheHelper.sharedPreferences.getBool(AppKeys.isLogin) ?? false;
    if (isLogin) return false;
    return CacheHelper.sharedPreferences.getBool(AppKeys.isGuest) ?? false;
  }

  static Future<void> enterGuestMode() async {
    await CacheHelper.sharedPreferences.setBool(AppKeys.isGuest, true);
    await CacheHelper.sharedPreferences.setBool(AppKeys.isLogin, false);
  }

  static Future<void> exitGuestMode() async {
    await CacheHelper.sharedPreferences.setBool(AppKeys.isGuest, false);
  }

  /// Marks a successful login: persists `isLogin = true` via CacheHelper
  /// and clears any stale guest flag so cold starts land on Home.
  static Future<void> markLoggedIn() async {
    await CacheHelper.sharedPreferences.setBool(AppKeys.isLogin, true);
    await CacheHelper.sharedPreferences.setBool(AppKeys.isGuest, false);
  }
}
