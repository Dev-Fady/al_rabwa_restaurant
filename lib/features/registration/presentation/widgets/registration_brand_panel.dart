import 'package:al_rabwa_restaurant/core/constants/app_assets.dart';
import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Brand showcase shown beside (or above) the registration form.
class RegistrationBrandPanel extends StatelessWidget {
  const RegistrationBrandPanel({super.key, required this.compact});

  /// Mobile layout: shorter copy and no feature list.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = context.appColors;
    final radius = BorderRadius.circular(compact ? 28 : 32);
    final padding = EdgeInsets.all(compact ? 24 : 40);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            appColors.brandGreen,
            Color.lerp(appColors.brandGreen, Colors.black, 0.32)!,
          ],
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: appColors.brandGreen.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -56,
            right: -42,
            child: _DecorativeCircle(
              size: compact ? 150 : 230,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: _DecorativeCircle(
              size: compact ? 170 : 260,
              color: appColors.accent.withValues(alpha: 0.10),
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BrandHeader(compact: compact),
                SizedBox(height: compact ? 22 : 48),
                Text(
                  l10n.registerWelcomeTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 25 : 40,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.registerWelcomeSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: compact ? 14 : 16,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 36),
                  _FeatureRow(
                    icon: Icons.restaurant_menu_rounded,
                    label: l10n.registerFeatureFresh,
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.delivery_dining_rounded,
                    label: l10n.registerFeatureFast,
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.verified_user_outlined,
                    label: l10n.registerFeatureSecure,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = context.appColors;
    final logoSize = compact ? 58.0 : 74.0;

    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(logoSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.restaurant,
              color: appColors.brandGreen,
              size: logoSize * 0.5,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.registerHeroBadge.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appColors.accent,
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.appTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 19 : 24,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, color: appColors.accent, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

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
