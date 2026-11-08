import 'package:al_rabwa_restaurant/core/constants/api_constants.dart';

/// Turns the media paths the API sends into absolute URLs.
///
/// Images usually arrive as full `https://` links, while dish videos come as
/// storage-relative paths such as `restaurants/1/items/clip.mp4`.
String resolveMediaUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';

  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasScheme) return value;

  final origin = Uri.parse(ApiConstants.baseUrl).origin;
  final path = value.startsWith('/') ? value.substring(1) : value;
  final storagePath = path.startsWith('storage/') ? path : 'storage/$path';

  return '$origin/$storagePath';
}
