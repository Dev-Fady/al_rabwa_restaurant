import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/menu/data/datasources/menu_items_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/repositories/menu_items_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class MenuItemsRepositoryImpl implements MenuItemsRepository {
  MenuItemsRepositoryImpl({required this.remoteDataSource});

  final MenuItemsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  }) async {
    try {
      final response = await remoteDataSource.getCategoryItems(
        categoryId: categoryId,
        lang: lang,
      );
      return Right(response.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
