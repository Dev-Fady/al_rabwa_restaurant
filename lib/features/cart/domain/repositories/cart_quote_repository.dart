import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';
import 'package:dartz/dartz.dart';

/// Quotes the current cart through `POST /api/cart/quote`.
abstract class CartQuoteRepository {
  /// Returns a freshly calculated quote and caches it. Callers fall back to
  /// [getCachedQuote] when the request fails.
  Future<Either<Failure, CartQuote>> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  });

  /// Last successful quote for exactly [cart] in [lang], if one was cached.
  CartQuote? getCachedQuote({required Cart cart, String lang = 'ar'});
}
