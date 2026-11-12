import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_local_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/datasources/cart_quote_remote_data_source.dart';
import 'package:al_rabwa_restaurant/features/cart/data/models/cart_quote_response.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Quotes the cart and keeps the last successful response in Hive, keyed by
/// the exact cart contents, order type and language.
class CartQuoteRepositoryImpl implements CartQuoteRepository {
  CartQuoteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final CartQuoteRemoteDataSource remoteDataSource;
  final CartQuoteLocalDataSource localDataSource;

  @override
  Future<Either<Failure, CartQuote>> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    try {
      final response = await remoteDataSource.fetchQuote(
        cart: cart,
        lang: lang,
      );
      final quote = response.toEntity();
      if (quote == null) {
        throw ServerFailure('Empty response from server.');
      }

      await _cache(cart, lang, response.toJson());
      return Right(quote);
    } on Failure catch (failure) {
      return Left(failure);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(ServerFailure.fromError(error));
    }
  }

  @override
  CartQuote? getCachedQuote({required Cart cart, String lang = 'ar'}) {
    try {
      final raw = localDataSource.read(key: _cacheKey(cart, lang));
      if (raw == null) return null;
      return CartQuoteResponse.fromJson(raw).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> _cache(
    Cart cart,
    String lang,
    Map<String, dynamic> payload,
  ) async {
    try {
      await localDataSource.save(key: _cacheKey(cart, lang), payload: payload);
    } catch (_) {
      // Caching is best-effort; the fresh quote is already in hand.
    }
  }

  /// Includes every field that changes the backend total, so a cached quote is
  /// never shown for a different cart.
  String _cacheKey(Cart cart, String lang) {
    final signature = StringBuffer();
    for (final line in cart.lines) {
      final addonIds = [
        for (final addon in line.addons)
          if (addon.id != null) addon.id,
      ]..sort();

      signature
        ..write(line.item.id)
        ..write(':')
        ..write(line.option?.id)
        ..write(':')
        ..write(line.weight.toStringAsFixed(3))
        ..write(':')
        ..write(line.quantity)
        ..write(':')
        ..write(addonIds.join(','))
        ..write(':')
        ..write(line.notes.trim())
        ..write('|');
    }

    return '${lang}_${cart.orderType}_$signature';
  }
}
