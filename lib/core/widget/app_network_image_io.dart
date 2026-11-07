import 'package:flutter/material.dart';

/// Network image for mobile/desktop: plain `Image.network`
/// (no CORS enforcement outside browsers).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fallbackIconSize = 36,
    this.fallbackColor,
    this.backgroundColor = const Color(0xFFF3E9E4),
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final double fallbackIconSize;
  final Color? fallbackColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        excludeFromSemantics: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: backgroundColor,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: backgroundColor,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_outlined,
            size: fallbackIconSize,
            color: fallbackColor,
          ),
        ),
      ),
    );
  }
}
