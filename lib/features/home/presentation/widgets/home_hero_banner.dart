import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Hero banner rendering dynamic promotional items matching the design:
/// - Food image on the trailing end, smoothly fading via gradient into dark green.
/// - Promotional title and subtitle in bold typography on the start side.
/// - Lime-green pill CTA button ("اطلب الآن >").
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({
    super.key,
    required this.banner,
    required this.restaurant,
    required this.onTap,
  });

  final HomeBanner? banner;
  final RestaurantBrand restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final accentColor = context.appColors.accent;
    final primaryColor = colors.primary;
    final hasImage = banner?.hasImage ?? false;
    final title = _firstNonEmpty([banner?.title, restaurant.name]);
    final subtitle = _firstNonEmpty([banner?.subtitle, restaurant.about]);
    final buttonLabel = _firstNonEmpty([banner?.buttonText, l10n.orderNow]);

    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bannerHeight = constraints.maxWidth / 2.03;

            return ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                constraints: BoxConstraints(minHeight: bannerHeight),
                color: primaryColor,
                child: Stack(
              children: [
                    // 1. Food image layer
                Positioned.fill(
                  child: hasImage
                      ? AppNetworkImage(
                          url: banner!.image,
                              fit: BoxFit.cover,
                              backgroundColor: primaryColor,
                              fallbackColor: colors.onPrimary.withValues(
                                alpha: 0.24,
                              ),
                          fallbackIconSize: 42,
                        )
                          : _BannerFallback(
                              brandGreen: primaryColor,
                              foregroundColor: colors.onPrimary,
                            ),
                    ),

                    // 2. Horizontal gradient overlay (solid dark green over text on start, fading to clear over image on end)
                    Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                            begin: AlignmentDirectional.centerStart,
                            end: AlignmentDirectional.centerEnd,
                            stops: const [0.0, 0.48, 0.78, 1.0],
                            colors: [
                              primaryColor,
                              primaryColor,
                              primaryColor.withValues(alpha: 0.56),
                              Colors.transparent,
                            ],
                      ),
                    ),
                  ),
                ),

                    // 3. Text & CTA Button content
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          24,
                          12,
                          24,
                          12,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth * 0.52,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onPrimary,
                                    fontSize: 28,
                                    height: 1.12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x80000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onPrimary.withValues(
                                      alpha: 0.95,
                                    ),
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // Lime-green CTA pill button ("اطلب الآن >")
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 160,
                                  minHeight: 54,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          buttonLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: colors.onSecondary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: colors.onSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback({
    required this.brandGreen,
    required this.foregroundColor,
  });

  final Color brandGreen;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            brandGreen, Color.lerp(brandGreen, Colors.black, 0.35)!,
          ],
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Icon(
            Icons.restaurant_menu,
            size: 64,
            color: foregroundColor.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}
