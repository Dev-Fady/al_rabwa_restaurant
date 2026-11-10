// import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 360;

          final height = isCompact ? 210.0 : 235.0;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: double.infinity,
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Large background food image.
                    if (hasImage)
                      AppNetworkImage(
                        url: banner!.image,
                        fit: BoxFit.cover,
                        backgroundColor: primaryColor,
                        fallbackColor: colors.surfaceContainerHighest,
                        fallbackIconSize: 48,
                      )
                    else
                      _BannerImageFallback(
                        primaryColor: primaryColor,
                        foregroundColor: colors.onPrimary,
                      ),

                    // 2. Dark gradient at the bottom.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.30, 0.55, 1.0],
                          colors: [
                            Color(0x00000000),
                            Color(0x18000000),
                            Color(0x99000000),
                            Color(0xE6000000),
                          ],
                        ),
                      ),
                    ),

                    // 3. Content.
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        20,
                        16,
                        20,
                        isCompact ? 16 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Restaurant brand.
                          if (restaurant.name.trim().isNotEmpty)
                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  restaurant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Title.
                          if (title.isNotEmpty)
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: isCompact ? 21 : 25,
                                height: 1.25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x55000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
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
                              textAlign: TextAlign.start,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontSize: isCompact ? 11 : 13,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // CTA.
                          Row(
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 42,
                                ),
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  17,
                                  9,
                                  14,
                                  9,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
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
                                          color: primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Icon(
                                      isRtl
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: primaryColor,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerImageFallback extends StatelessWidget {
  const _BannerImageFallback({
    required this.primaryColor,
    required this.foregroundColor,
  });

  final Color primaryColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color.lerp(primaryColor, Colors.black, 0.35)!],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 64,
          color: foregroundColor.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }

  return '';
}
