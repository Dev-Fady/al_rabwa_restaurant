import 'dart:async';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/errors/location_failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/device_location_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

/// Reads one high-accuracy GPS fix through the platform location services.
///
/// Only used by the optional "use my location" button: the map pin never
/// depends on it, so a denied permission or a missing fix only disables that
/// shortcut and never blocks saving an address.
class DeviceLocationRepositoryImpl implements DeviceLocationRepository {
  const DeviceLocationRepositoryImpl();

  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<Either<Failure, GeoPoint>> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return Left(LocationFailure(LocationIssue.serviceDisabled));
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.denied:
        case LocationPermission.unableToDetermine:
          return Left(LocationFailure(LocationIssue.permissionDenied));
        case LocationPermission.deniedForever:
          return Left(LocationFailure(LocationIssue.permissionDeniedForever));
        case LocationPermission.whileInUse:
        case LocationPermission.always:
          break;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _timeout,
        ),
      );

      return Right(
        GeoPoint(latitude: position.latitude, longitude: position.longitude),
      );
    } on TimeoutException {
      return Left(LocationFailure(LocationIssue.unavailable));
    } catch (_) {
      return Left(LocationFailure(LocationIssue.unavailable));
    }
  }
}
