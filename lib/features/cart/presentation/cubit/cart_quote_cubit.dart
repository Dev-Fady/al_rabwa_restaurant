import 'dart:async';

import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/repositories/cart_quote_repository.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:al_rabwa_restaurant/features/cart/presentation/cubit/cart_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keeps the server quote in sync with the cart and the selected order type.
///
/// Quoting starts only after the cart tab enables it, so adding dishes never
/// triggers a request until the customer actually opens the cart.
class CartQuoteCubit extends Cubit<CartQuoteState> {
  CartQuoteCubit(this._repository, this._cartCubit)
    : super(const CartQuoteState()) {
    _cartSubscription = _cartCubit.stream.listen(_onCartChanged);
  }

  final CartQuoteRepository _repository;
  final CartCubit _cartCubit;

  StreamSubscription<Cart>? _cartSubscription;
  bool _enabled = false;
  int _requestId = 0;
  String _signature = '';

  /// Called by the cart screen; also refreshes a quote that changed while the
  /// tab was hidden (order type on home, language change, ...).
  void enable({required String lang, Cart? cart}) {
    final targetLang = lang.trim().isEmpty ? 'ar' : lang;
    final langChanged = state.lang != targetLang;

    _enabled = true;
    if (langChanged) {
      emit(state.copyWith(lang: targetLang));
    }

    final shouldRetry = langChanged || state.status == CartQuoteStatus.failure;
    unawaited(
      load(cart ?? _cartCubit.state, lang: targetLang, force: shouldRetry),
    );
  }

  /// Reloads the quote when the app language changes.
  void setLang(String lang) {
    if (!_enabled) return;

    final targetLang = lang.trim().isEmpty ? 'ar' : lang;
    if (targetLang == state.lang) return;

    emit(state.copyWith(lang: targetLang));
    unawaited(load(_cartCubit.state, lang: targetLang, force: true));
  }

  Future<void> load(Cart cart, {String? lang, bool force = false}) async {
    if (isClosed) return;

    final targetLang = lang ?? state.lang;
    if (cart.isEmpty) {
      _signature = '';
      _requestId++;
      emit(CartQuoteState(lang: targetLang));
      return;
    }

    final signature = _signatureOf(cart);
    if (!force &&
        signature == _signature &&
        targetLang == state.lang &&
        state.status != CartQuoteStatus.initial) {
      return;
    }

    _signature = signature;
    final requestId = ++_requestId;

    final cached = _repository.getCachedQuote(cart: cart, lang: targetLang);
    emit(
      state.copyWith(
        quote: cached,
        clearQuote: cached == null,
        status: CartQuoteStatus.loading,
        clearError: true,
        isFromCache: cached != null,
        lang: targetLang,
      ),
    );

    final result = await _repository.fetchQuote(cart: cart, lang: targetLang);
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CartQuoteStatus.failure,
          errorMessage: failure.message,
          clearQuote: !state.hasQuote,
        ),
      ),
      (quote) => emit(
        state.copyWith(
          quote: quote,
          status: CartQuoteStatus.success,
          clearError: true,
          isFromCache: false,
        ),
      ),
    );
  }

  Future<void> retry() => load(_cartCubit.state, force: true);

  void _onCartChanged(Cart cart) {
    if (!_enabled || isClosed) return;
    unawaited(load(cart));
  }

  String _signatureOf(Cart cart) {
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
    return '${cart.orderType}_$signature';
  }

  @override
  Future<void> close() async {
    await _cartSubscription?.cancel();
    return super.close();
  }
}
