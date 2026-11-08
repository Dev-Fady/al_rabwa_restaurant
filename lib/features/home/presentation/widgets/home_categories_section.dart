import 'dart:async';

import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:al_rabwa_restaurant/core/widget/app_network_image.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_state.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter_bloc/flutter_bloc.dart';

/// "اكتشف المنيو" section.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    super.key,
    required this.onViewAll,
    required this.onCategoryTap,
  });

  final VoidCallback onViewAll;
  final ValueChanged<MenuCategory> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HomeCategoriesCubit, HomeCategoriesState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          !identical(previous.categories, current.categories),
      builder: (context, state) {
        final categories = state.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CategoriesHeader(
              title: l10n.homeCategoriesTitle,
              onViewAll: onViewAll,
            ),
            const SizedBox(height: 14),
            if (categories.isNotEmpty) ...[
              _CategoryCarousel(
                categories: categories,
                onCategoryTap: onCategoryTap,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.homeCategoriesHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ] else if (state.status == HomeCategoriesStatus.failure)
              _CategoriesError(
                onRetry: () =>
                    context.read<HomeCategoriesCubit>().load(refresh: true),
              )
            else
              const _CategoriesSkeleton(),
          ],
        );
      },
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 2,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: theme.textTheme.titleMedium?.copyWith(
            color: context.appColors.titleColor,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: context.appColors.brandGreen,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsetsDirectional.only(start: 12, end: 2),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.homeCategoriesViewAll,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  // decoration: TextDecoration.underline,
                  decorationThickness: 1.4,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                isRtl ? Icons.chevron_left : Icons.chevron_right,
                size: 18,
                color: context.appColors.brandGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Automatically scrolls smoothly back and forth.
class _CategoryCarousel extends StatefulWidget {
  const _CategoryCarousel({
    required this.categories,
    required this.onCategoryTap,
  });

  final List<MenuCategory> categories;
  final ValueChanged<MenuCategory> onCategoryTap;

  @override
  State<_CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<_CategoryCarousel>
    with SingleTickerProviderStateMixin {
  static const Duration _resumeDelay = Duration(seconds: 3);

  /// Continuous marquee speed in logical pixels per second.
  static const double _pixelsPerSecond = 34;

  final ScrollController _scrollController = ScrollController();

  late final Ticker _ticker;
  Timer? _resumeTimer;
  Duration _lastElapsed = Duration.zero;

  int _direction = 1;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    // A frame-driven marquee scrolls smoothly like a promo ticker and is
    // automatically paused by TickerMode when the section is off-screen.
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    _ticker.stop();
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;

    if (_isUserInteracting || delta <= Duration.zero) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final min = position.minScrollExtent;
    final max = position.maxScrollExtent;
    if (max <= min) return;

    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    var next = position.pixels + (_direction * _pixelsPerSecond * seconds);

    // Bounce at both ends instead of jumping back to the other side.
    if (next >= max) {
      next = max;
      _direction = -1;
    } else if (next <= min) {
      next = min;
      _direction = 1;
    }

    if ((next - position.pixels).abs() < 0.01) return;
    position.jumpTo(next);
  }

  void _startAutoScroll() {
    if (!mounted || _isUserInteracting || _ticker.isActive) return;
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void _pauseForUser() {
    _isUserInteracting = true;
    _resumeTimer?.cancel();
    _resumeTimer = null;
    if (_ticker.isActive) _ticker.stop();
  }

  void _scheduleResume() {
    _isUserInteracting = false;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeDelay, () {
      if (mounted) _startAutoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pauseForUser(),
      onPointerUp: (_) => _scheduleResume(),
      onPointerCancel: (_) => _scheduleResume(),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < widget.categories.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _CategoryCard(
                category: widget.categories[i],
                onTap: () => widget.onCategoryTap(widget.categories[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final MenuCategory category;
  final VoidCallback onTap;

  static const double _circleSize = 76;
  static const double _itemWidth = 92;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brandColor = context.appColors.brandGreen;

    return Semantics(
      button: true,
      label: category.name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SizedBox(
            width: _itemWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                    border: Border.all(
                      color: brandColor.withValues(alpha: 0.10),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x17000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: category.hasImage
                        ? SizedBox.expand(
                            child: AppNetworkImage(
                              url: category.image,
                              fit: BoxFit.cover,
                              backgroundColor: colors.surface,
                              fallbackColor: brandColor,
                              fallbackIconSize: 22,
                            ),
                          )
                        : _CategoryImageFallback(
                            brandColor: brandColor,
                            iconSize: _circleSize * 0.3,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback({
    required this.brandColor,
    required this.iconSize,
  });

  final Color brandColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            brandColor.withValues(alpha: 0.14),
            brandColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.restaurant_menu, size: iconSize, color: brandColor),
      ),
    );
  }
}

class _CategoriesError extends StatelessWidget {
  const _CategoriesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.homeCategoriesError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.35);

    return SizedBox(
      height: 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            for (var index = 0; index < 4; index++) ...[
              if (index > 0) const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: placeholder,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 56,
                    height: 10,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
