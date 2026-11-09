class MapConstants {
  MapConstants._();

  /// Raster tile template for the address map.
  ///
  /// The public OpenStreetMap servers are fine for development and low traffic
  /// but are not a production tile CDN (see the OSM tile usage policy). Swap
  /// this template for the project's own provider (MapTiler, Thunderforest,
  /// Stadia, ...) before heavy traffic — it keeps the `{z}/{x}/{y}` scheme.
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Sent in the tile requests' User-Agent, as the OSM policy requires.
  static const String tileUserAgentPackageName =
      'com.example.al_rabwa_restaurant';
}
