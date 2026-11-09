import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/datasources/addresses_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  AddressesRepositoryImpl({required this.remoteDataSource});

  final AddressesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, Address>> createAddress({
    required AddressKind kind,
    required String label,
    required String area,
    required String street,
    required String building,
    required String notes,
    required GeoPoint point,
    String lang = 'ar',
  }) async {
    try {
      final response = await remoteDataSource.createAddress(
        kind: kind,
        label: label,
        area: area,
        street: street,
        building: building,
        notes: notes,
        point: point,
        lang: lang,
      );

      final address = response.toEntity();
      if (address == null) {
        return Left(
          ServerFailure(
            response.message.isEmpty
                ? 'Empty response from server.'
                : response.message,
          ),
        );
      }

      return Right(address);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
