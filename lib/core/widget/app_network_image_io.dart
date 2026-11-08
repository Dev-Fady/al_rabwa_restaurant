import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Network image for mobile/desktop using Flutter's built-in NetworkImage
/// with dynamic decode sizing (`cacheWidth`/`cacheHeight`) based on rendered
/// dimensions and DPR to avoid decoding multi-megapixel images in full resolution.
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
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: _buildFallback(),
      );
    }

    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;

    // Calculate decode size based on display constraints & DPR.
    // If width or height is defined, scale by DPR. If neither is defined
    // (e.g. flexible / expanded image), cap cacheWidth based on screen width.
    int? cacheWidth;
    int? cacheHeight;

    if (width != null && width!.isFinite && width! > 0) {
      cacheWidth = (width! * dpr).round();
      if (height != null && height!.isFinite && height! > 0) {
        cacheHeight = (height! * dpr).round();
      }
    } else if (height != null && height!.isFinite && height! > 0) {
      cacheHeight = (height! * dpr).round();
    } else {
      // Unbounded/flexible container: cap to screen width or 800px max
      final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 400.0;
      cacheWidth = math.min((screenWidth * dpr).round(), 800);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
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
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: fallbackIconSize,
        color: fallbackColor,
      ),
    );
  }
}
