import 'package:al_rabwa_restaurant/core/theme/store_colors.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Shimmering placeholder shown while the storefront settings are loading.
///
/// It mirrors the real home layout (header, delivery bar, order types, search,
/// hero banner and categories) so the content does not jump when the settings
/// arrive.
class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({super.key});

  /// Matches the centered content column of the loaded home screen.
  static const double _maxContentWidth = 760;

  /// Matches the hero banner's height on regular phone widths.
  static const double _bannerHeight = 235;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.loadingStore,
      container: true,
      child: _Shimmer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: ListView(
                  key: const ValueKey('home-loading-shimmer'),
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    32,
                  ),
                  children: const [
                    _HeaderShimmer(),
                    SizedBox(height: 14),
                    _ShimmerBlock(height: 52, radius: 16),
                    SizedBox(height: 12),
                    _OrderTypesShimmer(),
                    SizedBox(height: 12),
                    _ShimmerBlock(height: 52, radius: 20),
                    SizedBox(height: 18),
                    _ShimmerBlock(height: _bannerHeight, radius: 24),
                    SizedBox(height: 42),
                    _CategoriesShimmer(),
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

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ShimmerBlock(width: 156, height: 26, radius: 8),
          ),
        ),
        SizedBox(width: 8),
        _ShimmerBlock(width: 78, height: 36, radius: 20),
        SizedBox(width: 8),
        _ShimmerBlock(width: 48, height: 48, radius: 12),
      ],
    );
  }
}

class _OrderTypesShimmer extends StatelessWidget {
  const _OrderTypesShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ShimmerBlock(height: 52, radius: 16)),
        SizedBox(width: 10),
        Expanded(child: _ShimmerBlock(height: 52, radius: 16)),
      ],
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            _ShimmerBlock(width: 110, height: 20, radius: 6),
            Spacer(),
            _ShimmerBlock(width: 68, height: 16, radius: 6),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (var index = 0; index < 4; index++) ...[
                    if (index > 0) const SizedBox(width: 10),
                    const Column(
                      children: [
                        _ShimmerBlock(width: 76, height: 76, radius: 38),
                        SizedBox(height: 8),
                        _ShimmerBlock(width: 56, height: 10, radius: 4),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: _ShimmerBlock(width: 180, height: 10, radius: 4)),
      ],
    );
  }
}

/// A single placeholder shape; the [ShaderMask] in [_Shimmer] paints the
/// moving gradient over it.
class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({this.width, required this.height, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.storeColors.photoBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Sweeps a highlight gradient over [child] using the store palette used for
/// image placeholders.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 1400);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.storeColors;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // The gradient band travels from outside the start edge to outside the
        // end edge, so the highlight sweeps across the whole layout.
        final slide = _controller.value * 4 - 2;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(slide, 0),
            end: Alignment(slide + 2, 0),
            colors: [
              colors.photoBackground,
              colors.shimmerHighlight,
              colors.photoBackground,
            ],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}
