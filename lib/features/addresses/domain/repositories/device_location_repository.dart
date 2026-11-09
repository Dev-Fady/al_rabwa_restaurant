import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:dartz/dartz.dart';

/// Reads the device's current GPS coordinate for the "use my location" action.
abstract class DeviceLocationRepository {
  Future<Either<Failure, GeoPoint>> currentLocation();
}
