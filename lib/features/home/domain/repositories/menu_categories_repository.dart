import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:dartz/dartz.dart';

/// Reads the menu sections shown on the home storefront.
abstract class MenuCategoriesRepository {
  /// Fetches `GET /api/categories?lang=...`.
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  });
}
