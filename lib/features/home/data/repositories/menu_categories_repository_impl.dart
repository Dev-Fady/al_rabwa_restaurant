import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/menu_categories_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class MenuCategoriesRepositoryImpl implements MenuCategoriesRepository {
  MenuCategoriesRepositoryImpl({required this.remoteDataSource});

  final MenuCategoriesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async {
    try {
      final response = await remoteDataSource.getCategories(lang: lang);
      return Right(response.toEntities());
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
