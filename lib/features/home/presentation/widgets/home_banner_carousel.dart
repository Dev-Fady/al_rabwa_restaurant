import 'dart:async';
import 'dart:math' as math;

import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_hero_banner.dart';
import 'package:flutter/material.dart';

/// Swipeable promo banners with a page indicator, matching the design.
///
/// The banners advance every [_autoPlayInterval] and pause while the user is
/// interacting with them. A single banner is rendered without a page view, an
/// empty list falls back to the restaurant-branded banner.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
    required this.banners,
    required this.restaurant,
    required this.onBannerTap,
  });

  final List<HomeBanner> banners;
  final RestaurantBrand restaurant;
  final ValueChanged<HomeBanner> onBannerTap;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  /// How long each banner stays on screen.
  static const Duration _autoPlayInterval = Duration(seconds: 4);

  /// Duration of the slide to the next banner.
  static const Duration _autoPlayAnimation = Duration(milliseconds: 450);

  final PageController _controller = PageController();
  Timer? _autoPlayTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _page = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    if (widget.banners.length < 2) {
      return;
    }
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) => _showNext());
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _showNext() {
    if (!mounted || widget.banners.length < 2 || !_controller.hasClients) {
      return;
    }

    final next = (_page + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: _autoPlayAnimation,
      curve: Curves.easeInOut,
    );
  }

  /// Keeps room for two title lines, the subtitle and the CTA, and scales
  /// with the user's text size so the copy never overflows.
  double _heightFor(BuildContext context, double width) {
    final scaler = MediaQuery.textScalerOf(context);
    final titleLine = scaler.scale(26) * 1.4;
    final subtitleLine = scaler.scale(13.5) * 1.6;
    final subtitleLines = scaler.scale(1) > 1.25 ? 2 : 1;
    final buttonHeight = math.max(44.0, scaler.scale(15) + 20);
    final content =
        18 +
        titleLine * 2 +
        8 +
        subtitleLine * subtitleLines +
        14 +
        buttonHeight +
        26 +
        16;
    final ratioHeight = (width / 2.15).clamp(170.0, 300.0);

    return math.max(ratioHeight, content);
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = _heightFor(context, constraints.maxWidth);

        if (banners.isEmpty) {
          return SizedBox(
            height: height,
            child: HomeHeroBanner(
              banner: null,
              restaurant: widget.restaurant,
              onTap: () => widget.onBannerTap(const HomeBanner()),
            ),
          );
        }

        if (banners.length == 1) {
          final banner = banners.single;
          return SizedBox(
            height: height,
            child: HomeHeroBanner(
              banner: banner,
              restaurant: widget.restaurant,
              onTap: () => widget.onBannerTap(banner),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                onPointerDown: (_) => _stopAutoPlay(),
                onPointerUp: (_) => _startAutoPlay(),
                onPointerCancel: (_) => _startAutoPlay(),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: banners.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return HomeHeroBanner(
                      banner: banner,
                      restaurant: widget.restaurant,
                      onTap: () => widget.onBannerTap(banner),
                    );
                  },
                ),
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 10,
                child: IgnorePointer(
                  child: _BannerPageIndicator(
                    count: banners.length,
                    current: _page.clamp(0, banners.length - 1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BannerPageIndicator extends StatelessWidget {
  const _BannerPageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final accent = context.appColors.accent;

    return Row(
      key: const ValueKey('home-banner-indicators'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) const SizedBox(width: 6),
          AnimatedContainer(
            key: ValueKey('home-banner-dot-$index'),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: index == current ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == current
                  ? accent
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
    );
  }
}
