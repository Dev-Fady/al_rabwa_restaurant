import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:dartz/dartz.dart';

/// Reads and creates delivery addresses through `/api/addresses`.
abstract class AddressesRepository {
  Future<Either<Failure, List<Address>>> fetchAddresses({String lang = 'ar'});

  Future<Either<Failure, Address>> fetchAddress({
    required int id,
    String lang = 'ar',
  });

  Future<Either<Failure, Address>> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  });

  Future<Either<Failure, Address>> updateAddress({
    required int id,
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  });
}
