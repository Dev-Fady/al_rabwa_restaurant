import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/utils/auth_helper.dart';
import 'package:al_rabwa_restaurant/features/registration/data/datasources/device_registration_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/entities/device_session.dart';
import 'package:al_rabwa_restaurant/features/registration/domain/repositories/device_registration_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceRegistrationRepositoryImpl implements DeviceRegistrationRepository {
  DeviceRegistrationRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  final DeviceRegistrationRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  @override
  Future<Either<Failure, DeviceSession>> registerDevice({
    required String name,
    required String phone,
    required String locale,
  }) async {
    try {
      final response = await remoteDataSource.registerDevice(
        name: name,
        phone: phone,
        locale: locale,
      );

      final session = response.toEntity();
      if (session == null) {
        return Left(
          ServerFailure(
            response.message.isEmpty
                ? 'Empty response from server.'
                : response.message,
          ),
        );
      }

      try {
        await AuthHelper.saveSession(secureStorage, token: session.token);
      } catch (_) {
        // The backend issued a token but it could not be stored, so the
        // session cannot survive a restart. Surface an empty message so the
        // UI can show its localized fallback.
        return Left(ServerFailure(''));
      }

      return Right(session);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
