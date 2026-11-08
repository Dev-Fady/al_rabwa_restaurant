import 'package:al_rabwa_restaurant/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Banner at the top of the "أقسام المنيو" page: a short welcome message and
/// the number of sections available, with a decorative sparkle in the corner.
class MenuCategoriesHero extends StatelessWidget {
  const MenuCategoriesHero({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brandColor = context.appColors.brandGreen;
    final onBrand = colors.onPrimary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: brandColor,
        child: Stack(
          children: [
            Positioned(
              left: -30,
              bottom: -42,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(160, 160),
                  painter: _SparklePainter(
                    color: Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.13),
                      brandColor,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onBrand,
                      fontWeight: FontWeight.w600,
                      // letterSpacing: -0.4,
                      // height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onBrand.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w400,
                      // height: 1.4,
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

/// Four-point sparkle used as a soft brand decoration.
class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final path = Path()
      ..moveTo(width / 2, 0)
      ..quadraticBezierTo(width * 0.62, height * 0.38, width, height / 2)
      ..quadraticBezierTo(width * 0.62, height * 0.62, width / 2, height)
      ..quadraticBezierTo(width * 0.38, height * 0.62, 0, height / 2)
      ..quadraticBezierTo(width * 0.38, height * 0.38, width / 2, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
