import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/tables/domain/entities/dining_table.dart';
import 'package:dartz/dartz.dart';

/// Reads the dine-in tables through `/api/tables`.
abstract class TablesRepository {
  Future<Either<Failure, List<DiningTable>>> fetchTables({String lang = 'ar'});
}
