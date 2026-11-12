import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/entities/order_draft.dart';
import 'package:al_rabwa_restaurant/features/orders/domain/repositories/orders_repository.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({required this.remoteDataSource});

  final OrdersRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, Order>> createOrder({
    required Cart cart,
    required OrderDraft draft,
    required String idempotencyKey,
    String lang = 'ar',
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        cart: cart,
        draft: draft,
        idempotencyKey: idempotencyKey,
        lang: lang,
      );
      return Right(order);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }
}
