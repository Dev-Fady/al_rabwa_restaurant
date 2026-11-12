import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart_quote.dart';

enum CartQuoteStatus { initial, loading, success, failure }

class CartQuoteState {
  const CartQuoteState({
    this.quote,
    this.status = CartQuoteStatus.initial,
    this.errorMessage,
    this.isFromCache = false,
    this.lang = 'ar',
  });

  final CartQuote? quote;
  final CartQuoteStatus status;
  final String? errorMessage;

  /// The quote currently shown came from Hive, not the latest request.
  final bool isFromCache;

  final String lang;

  bool get hasQuote => quote != null;

  bool get isLoading => status == CartQuoteStatus.loading;

  bool get hasError => status == CartQuoteStatus.failure;

  CartQuoteState copyWith({
    CartQuote? quote,
    bool clearQuote = false,
    CartQuoteStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? isFromCache,
    String? lang,
  }) {
    return CartQuoteState(
      quote: clearQuote ? null : (quote ?? this.quote),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
      lang: lang ?? this.lang,
    );
  }
}
