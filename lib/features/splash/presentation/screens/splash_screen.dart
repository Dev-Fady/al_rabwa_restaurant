import 'dart:async';

import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

/// First screen shown on a cold start. Opens the device registration flow on
/// a fresh install and the storefront once a token has been saved.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _displayDuration = Duration(milliseconds: 1400);

  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_displayDuration, _openNextScreen);
  }

  Future<void> _openNextScreen() async {
    final hasToken = await _hasSavedToken();
    if (!mounted) return;

    context.go(hasToken ? AppRoutes.home : AppRoutes.registration);
  }

  Future<bool> _hasSavedToken() async {
    try {
      if (!getIt.isRegistered<FlutterSecureStorage>()) return false;
      return await AuthHelper.hasSavedToken(getIt<FlutterSecureStorage>());
    } catch (_) {
      // Storage is unavailable (tests, web private mode): treat the device as
      // new and let the registration screen handle the session.
      return false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant, size: 72, color: colors.onPrimary),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
