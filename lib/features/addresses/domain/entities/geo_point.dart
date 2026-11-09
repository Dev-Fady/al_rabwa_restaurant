/// A WGS84 coordinate pair for a delivery address.
///
/// Coordinates always come from the map itself: the pin is fixed at the center
/// of the map, so whatever the customer pans to is exactly what is submitted.
/// The camera is constrained to [qatarBounds] because the restaurant only
/// delivers inside Qatar; [isWithinQatar] is the last guard before a save.
class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  /// Doha city centre. The map opens here because almost every order is in
  /// Qatar, so the customer rarely has to pan more than a few streets.
  static const GeoPoint qatarCenter = GeoPoint(
    latitude: 25.2854,
    longitude: 51.5310,
  );

  /// Qatar's bounding box (mainland plus the near-shore islands), used to
  /// keep the picker and the saved coordinate inside the delivery country.
  static const double minLatitude = 24.45;
  static const double maxLatitude = 26.20;
  static const double minLongitude = 50.70;
  static const double maxLongitude = 51.70;

  final double latitude;
  final double longitude;

  bool get isWithinQatar =>
      latitude >= minLatitude &&
      latitude <= maxLatitude &&
      longitude >= minLongitude &&
      longitude <= maxLongitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoPoint &&
          other.latitude == latitude &&
          other.longitude == longitude);

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
