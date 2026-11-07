import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_category_items.dart';
import 'package:al_rabwa_restaurant/features/menu/domain/entities/menu_item_details.dart';
import 'package:dartz/dartz.dart';

/// Reads the dishes of one menu category and single dish details.
abstract class MenuItemsRepository {
  /// Fetches `GET /api/categories/{categoryId}/items?lang=...`.
  Future<Either<Failure, MenuCategoryItems>> fetchItems({
    required int categoryId,
    String lang = 'ar',
  });

  /// Fetches `GET /api/items/{itemId}?lang=...`.
  Future<Either<Failure, MenuItemDetails>> fetchItemDetails({
    required int itemId,
    String lang = 'ar',
  });
}
