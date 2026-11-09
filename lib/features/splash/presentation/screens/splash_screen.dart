import 'dart:async';

import 'package:al_rabwa_restaurant/core/constants/app_assets.dart';
import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

/// First screen shown on a cold start. Opens the device registration flow on
/// a fresh install and the storefront once a token has been saved.
///
/// The entrance is choreographed (glow, logo, title, tagline, loader) and the
/// logo keeps a slow breathing pulse while the token check runs.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _displayDuration = Duration(milliseconds: 1800);

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loaderFade;

  Timer? _timer;
  bool _reduceMotionApplied = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _taglineFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.42, 0.9, curve: Curves.easeOut),
    );
    _loaderFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1, curve: Curves.easeOut),
    );

    _entranceController.forward();
    _pulseController.repeat(reverse: true);
    _timer = Timer(_displayDuration, _openNextScreen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion && !_reduceMotionApplied) {
      _reduceMotionApplied = true;
      _entranceController.value = 1;
      _pulseController
        ..stop()
        ..value = 0.5;
    }
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
    _timer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = context.appColors;
    final backgroundBottom = Color.lerp(
      appColors.brandGreen,
      Colors.black,
      0.55,
    )!;

    return Scaffold(
      backgroundColor: appColors.brandGreen,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [appColors.brandGreen, backgroundBottom],
              ),
            ),
          ),
          _SplashBackdrop(accent: appColors.accent),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 24 : 32,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AnimatedLogo(
                            scale: _logoScale,
                            fade: _logoFade,
                            pulse: _pulseController,
                            accent: appColors.accent,
                            brandColor: appColors.brandGreen,
                            size: compact ? 98 : 116,
                          ),
                          SizedBox(height: compact ? 24 : 32),
                          FadeTransition(
                            opacity: _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: Text(
                                l10n.appTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: compact ? 24 : 30,
                                  height: 1.15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              l10n.splashTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: compact ? 14 : 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 34 : 46),
                          FadeTransition(
                            opacity: _loaderFade,
                            child: _SplashLoader(
                              accent: appColors.accent,
                              label: l10n.splashLoading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({
    required this.scale,
    required this.fade,
    required this.pulse,
    required this.accent,
    required this.brandColor,
    required this.size,
  });

  final Animation<double> scale;
  final Animation<double> fade;
  final Animation<double> pulse;
  final Color accent;
  final Color brandColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final t = pulse.value;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Breathing halo behind the mark.
                Transform.scale(
                  scale: 1 + t * 0.1,
                  child: Container(
                    width: size * 1.58,
                    height: size * 1.58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.07 + t * 0.07),
                    ),
                  ),
                ),
                Container(
                  width: size * 1.34,
                  height: size * 1.34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16 + t * 0.12),
                      width: 1.4,
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.24),
                  blurRadius: 44,
                ),
              ],
            ),
            child: Image.asset(
              AppAssets.logo,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.restaurant_rounded,
                color: brandColor,
                size: size * 0.48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader({required this.accent, required this.label});

  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              backgroundColor: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          const SizedBox(height: 14),
          ExcludeSemantics(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative light pools and rings that keep the background from feeling flat.
class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          PositionedDirectional(
            top: -130,
            end: -90,
            child: _GlowCircle(
              size: 330,
              color: accent.withValues(alpha: 0.12),
            ),
          ),
          PositionedDirectional(
            bottom: -170,
            start: -120,
            child: _GlowCircle(
              size: 380,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          PositionedDirectional(
            top: 80,
            start: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
