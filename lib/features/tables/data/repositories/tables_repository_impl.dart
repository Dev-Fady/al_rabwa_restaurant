import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/tables/data/datasources/tables_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/repositories/tables_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TablesRepositoryImpl implements TablesRepository {
  TablesRepositoryImpl({required this.remoteDataSource});

  final TablesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<DiningTable>>> fetchTables({
    String lang = 'ar',
  }) async {
    try {
      final tables = await remoteDataSource.fetchTables(lang: lang);
      return Right(tables);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
