import 'package:al_rabwa_restaurant/core/error/failure.dart';

/// Why the device location could not be used. The UI owns the localized copy.
enum LocationIssue {
  /// Location services (GPS) are turned off system-wide.
  serviceDisabled,

  /// The user declined this time; asking again is allowed.
  permissionDenied,

  /// The user declined permanently; only system settings can re-enable it.
  permissionDeniedForever,

  /// Permission was granted but no fix arrived (timeout, indoor, etc.).
  unavailable,
}

class LocationFailure extends Failure {
  LocationFailure(this.issue) : super(issue.name);

  final LocationIssue issue;
}
