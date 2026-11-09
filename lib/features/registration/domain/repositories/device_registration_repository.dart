import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/entities/device_session.dart';
import 'package:dartz/dartz.dart';

/// Registers this device with the restaurant backend and stores its session.
abstract class DeviceRegistrationRepository {
  Future<Either<Failure, DeviceSession>> registerDevice({
    required String name,
    required String phone,
    required String locale,
  });
}
