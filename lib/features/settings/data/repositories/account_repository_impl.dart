import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/features/settings/data/datasources/account_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/settings/domain/repositories/account_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  final AccountRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  @override
  Future<Either<Failure, Unit>> deleteMyData() async {
    try {
      await remoteDataSource.deleteMyData();

      // The device no longer exists on the backend, so its token is unusable.
      // Clearing the session keeps the next protected call from sending it.
      await AuthHelper.clearSession(secureStorage);
      return Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
