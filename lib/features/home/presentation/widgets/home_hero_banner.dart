import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Promotional hero banner matching the design:
/// - full-bleed food photo on the trailing side, fading into dark green;
/// - white title and subtitle on the leading side;
/// - lime-green pill CTA ("اطلب الآن ‹").
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
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
            final width = constraints.maxWidth;

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: primaryColor,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Food photo on the trailing side, leaving the leading
                    // side free for the copy.
                    PositionedDirectional(
                      top: 0,
                      bottom: 0,
                      end: 0,
                      width: width * 0.56,
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
                          : _BannerImageFallback(
                              brandGreen: primaryColor,
                              foregroundColor: colors.onPrimary,
                            ),
                    ),

                    // 2. Dark green wash that keeps the copy readable and
                    // melts the photo into the card. The fade stops right at
                    // the photo's edge so the food keeps its own colors.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AlignmentDirectional.centerStart,
                            end: AlignmentDirectional.centerEnd,
                            stops: const [0.0, 0.30, 0.35, 0.55, 0.65, 1.0],
                            colors: [
                              primaryColor,
                              primaryColor,
                              primaryColor.withValues(alpha: 0.95),
                              primaryColor.withValues(alpha: 0.65),
                              primaryColor.withValues(alpha: 0.15),
                              primaryColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Copy and CTA.
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          24,
                          18,
                          24,
                          26,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width * 0.54),
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
                                    fontSize: 23,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.4,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x59000000),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onPrimary.withValues(
                                      alpha: 0.92,
                                    ),
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              // Lime-green CTA pill ("اطلب الآن ‹").
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 96,
                                  minHeight: 44,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x2E000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        buttonLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.onSecondary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      isRtl
                                          ? Icons.chevron_left
                                          : Icons.chevron_right,
                                      size: 19,
                                      color: colors.onSecondary,
                                    ),
                                  ],
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

class _BannerImageFallback extends StatelessWidget {
  const _BannerImageFallback({
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
          colors: [brandGreen, Color.lerp(brandGreen, Colors.black, 0.35)!],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 56,
          color: foregroundColor.withValues(alpha: 0.18),
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
