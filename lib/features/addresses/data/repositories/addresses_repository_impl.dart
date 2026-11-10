import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/datasources/addresses_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/addresses/data/models/address_response.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/address.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/entities/geo_point.dart';
import 'package:al_rabwa_restaurant/features/addresses/domain/repositories/addresses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  AddressesRepositoryImpl({required this.remoteDataSource});

  final AddressesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Address>>> fetchAddresses({
    String lang = 'ar',
  }) async {
    try {
      final addresses = await remoteDataSource.fetchAddresses(lang: lang);
      return Right(addresses);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }

  @override
  Future<Either<Failure, Address>> fetchAddress({
    required int id,
    String lang = 'ar',
  }) {
    return _run(() => remoteDataSource.fetchAddress(id: id, lang: lang));
  }

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
  }) {
    return _run(
      () => remoteDataSource.createAddress(
        kind: kind,
        label: label,
        area: area,
        street: street,
        building: building,
        notes: notes,
        point: point,
        lang: lang,
      ),
    );
  }

  @override
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
  }) {
    return _run(
      () => remoteDataSource.updateAddress(
        id: id,
        kind: kind,
        label: label,
        area: area,
        street: street,
        building: building,
        notes: notes,
        point: point,
        lang: lang,
      ),
    );
  }

  @override
  Future<Either<Failure, Address>> setDefaultAddress({
    required int id,
    String lang = 'ar',
  }) {
    return _run(() => remoteDataSource.setDefaultAddress(id: id, lang: lang));
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress({
    required int id,
    String lang = 'ar',
  }) async {
    try {
      await remoteDataSource.deleteAddress(id: id, lang: lang);
      return Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }

  /// Runs one address request and maps its envelope to [Address].
  Future<Either<Failure, Address>> _run(
    Future<AddressResponse> Function() request,
  ) async {
    try {
      final response = await request();
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
