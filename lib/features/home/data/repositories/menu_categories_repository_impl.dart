import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/data/datasources/menu_categories_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class MenuCategoriesRepositoryImpl implements MenuCategoriesRepository {
  MenuCategoriesRepositoryImpl({required this.remoteDataSource});

  final MenuCategoriesRemoteDataSource remoteDataSource;
  final Map<String, List<MenuCategory>> _memoryCache = {};

  void clearCache() {
    _memoryCache.clear();
  }

  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async {
    final cached = _memoryCache[lang];
    if (cached != null && cached.isNotEmpty) {
      return Right(cached);
    }

    try {
      final response = await remoteDataSource.getCategories(lang: lang);
      final categories = response.toEntities();
      _memoryCache[lang] = categories;
      return Right(categories);
    } on Failure catch (failure) {
      final fallback = _memoryCache[lang];
      if (fallback != null && fallback.isNotEmpty) return Right(fallback);
      return Left(failure);
    } on DioException catch (error) {
      final fallback = _memoryCache[lang];
      if (fallback != null && fallback.isNotEmpty) return Right(fallback);
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      final fallback = _memoryCache[lang];
      if (fallback != null && fallback.isNotEmpty) return Right(fallback);
      return Left(ServerFailure.fromError(error));
    }
  }
}
