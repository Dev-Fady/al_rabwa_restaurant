import 'package:al_rabwa_restaurant/core/constants/app_keys.dart';
import 'package:al_rabwa_restaurant/core/helper_functions/cache_helper.dart';
import 'package:flutter/material.dart' hide Slider;
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static bool get _isLoggedIn {
    try {
      return CacheHelper.sharedPreferences.getBool(AppKeys.isLogin) ?? false;
    } catch (_) {
      // SharedPreferences not ready (e.g. widget tests): treat as logged out.
      return false;
    }
  }

  static bool get _isGuest {
    try {
      return CacheHelper.sharedPreferences.getBool(AppKeys.isGuest) ?? false;
    } catch (_) {
      return false;
    }
  }



  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    // Cold start always lands on the splash; once its entrance animation
    // finishes, the splash sends the user to home or login.
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    // redirect: (context, state) {
    //   final authenticated = _isLoggedIn || _isGuest;
    //   final location = state.matchedLocation;
    //   const authLocations = {
    //     AppRoutes.login,
    //     AppRoutes.signup,
    //     AppRoutes.verifyOtp,
    //     AppRoutes.forgotPassword,
    //     AppRoutes.resetPassword,
    //   };
    //   // Let the splash play; it navigates to its destination when done.
    //   if (location == AppRoutes.splash) return null;
    //   if (!authenticated && !authLocations.contains(location)) {
    //     return AppRoutes.login;
    //   }
    //   if (authenticated && location == AppRoutes.login) {
    //     return AppRoutes.home;
    //   }
    //   return null;
    // },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
        
        },
      ),
    
  ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير موجودة\n${state.uri.toString()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}
