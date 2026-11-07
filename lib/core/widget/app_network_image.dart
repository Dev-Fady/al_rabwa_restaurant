// Shared network image that renders on every platform.
//
// Web (CanvasKit) fetches `Image.network` bytes via `fetch`, which the
// browser blocks when the file server omits CORS headers. Mobile/desktop
// are unaffected. The web implementation below renders a plain `<img>`
// element instead, which browsers allow to display cross-origin.
export 'app_network_image_io.dart'
    if (dart.library.html) 'app_network_image_web.dart';
