import 'package:al_rabwa_restaurant/core/routes/app_routes.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_cubit.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/cubit/device_registration_state.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/widgets/registration_brand_panel.dart';
import 'package:al_rabwa_restaurant/features/registration/presentation/widgets/registration_form_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// First-run screen that registers the device and stores its bearer token.
class DeviceRegistrationScreen extends StatelessWidget {
  const DeviceRegistrationScreen({super.key, this.onLocaleChanged});

  /// Wired to the app-level settings cubit by the router.
  final ValueChanged<String>? onLocaleChanged;

  /// Below this width the panel and form stack vertically.
  static const double _wideBreakpoint = 920;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceRegistrationCubit, DeviceRegistrationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.isSuccess,
      listener: (context, state) {
        if (context.canPop()) {
          context.pop(true);
        } else {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _RegistrationBackground(),
            SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= _wideBreakpoint;
                      final horizontalPadding = constraints.maxWidth >= 600
                          ? 32.0
                          : 16.0;

                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          24,
                          horizontalPadding,
                          28,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWide ? 1120 : 540,
                            ),
                            child: isWide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(
                                        flex: 5,
                                        child: RegistrationBrandPanel(
                                          compact: false,
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 4,
                                        child: RegistrationFormCard(
                                          onLocaleChanged: onLocaleChanged,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const RegistrationBrandPanel(compact: true),
                                      const SizedBox(height: 20),
                                      RegistrationFormCard(
                                        onLocaleChanged: onLocaleChanged,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (context.canPop())
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
                          child: BackButton(
                            color: Colors.white,
                            onPressed: () => context.pop(false),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationBackground extends StatelessWidget {
  const _RegistrationBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colors.surface,
              appColors.background,
              colors.primaryContainer.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _GlowCircle(
                size: 270,
                color: appColors.accent.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: _GlowCircle(
                size: 320,
                color: colors.primary.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
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
