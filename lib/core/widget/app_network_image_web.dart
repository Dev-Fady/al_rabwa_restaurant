import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Network image for Flutter Web.
///
/// Unlike `Image.network` (bytes fetched via `fetch` and blocked without
/// the server's `Access-Control-Allow-Origin` header), a plain `<img>`
/// element is allowed to *display* cross-origin images, exactly like
/// opening the URL in a browser tab.
///
/// Built on [HtmlElementView.fromTagName], so each instance owns its
/// `<img>` element directly: no per-URL view factory is registered, no
/// global registry grows with the catalog size, and nothing goes stale
/// across navigation or hot restart.
class AppNetworkImage extends StatefulWidget {
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
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

String _fitToCss(BoxFit fit) => switch (fit) {
  BoxFit.contain => 'contain',
  BoxFit.cover => 'cover',
  BoxFit.fill => 'fill',
  BoxFit.fitWidth => 'cover',
  BoxFit.fitHeight => 'cover',
  BoxFit.none => 'none',
  BoxFit.scaleDown => 'scale-down',
};

class _AppNetworkImageState extends State<AppNetworkImage> {
  bool _settled = false;
  bool _failed = false;

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _settled = false;
      _failed = false;
    }
  }

  void _configureImage(Object element) {
    final img = element as web.HTMLImageElement
      ..src = widget.url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = _fitToCss(widget.fit)
      ..style.display = 'block'
      // Display-only: let clicks pass through to Flutter so the
      // surrounding GestureDetector/InkWell keeps working on web
      // (otherwise the platform view swallows every pointer event).
      ..style.pointerEvents = 'none'
      ..alt = '';
    img.addEventListener(
      'load',
      ((web.Event _) {
        if (mounted) setState(() => _settled = true);
      }).toJS,
    );
    img.addEventListener(
      'error',
      ((web.Event _) {
        if (mounted) setState(() => _settled = _failed = true);
      }).toJS,
    );
  }

  @override
  Widget build(BuildContext context) {
    final object = _failed
        ? Container(
            width: widget.width,
            height: widget.height,
            color: widget.backgroundColor,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              size: widget.fallbackIconSize,
              color: widget.fallbackColor,
            ),
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.width,
                height: widget.height,
                // Keyed by URL + fit: the `<img>` element is created once
                // per view, so a new URL/fit must create a new view.
                child: HtmlElementView.fromTagName(
                  key: ValueKey('app-img-${widget.url}-${widget.fit.name}'),
                  tagName: 'img',
                  onElementCreated: _configureImage,
                ),
              ),
              if (!_settled)
                Container(
                  width: widget.width,
                  height: widget.height,
                  color: widget.backgroundColor,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );

    if (widget.borderRadius == BorderRadius.zero) return object;
    return ClipRRect(borderRadius: widget.borderRadius, child: object);
  }
}
