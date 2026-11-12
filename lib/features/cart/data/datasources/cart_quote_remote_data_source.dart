import 'dart:convert';

import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/services/api/api_service.dart';
import 'package:al_rabwa_restaurant/features/cart/domain/entities/cart.dart';

import '../models/cart_quote_response.dart';

/// Sends the current cart to `POST /api/cart/quote`.
abstract class CartQuoteRemoteDataSource {
  Future<CartQuoteResponse> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  });
}

class CartQuoteRemoteDataSourceImpl implements CartQuoteRemoteDataSource {
  CartQuoteRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<CartQuoteResponse> fetchQuote({
    required Cart cart,
    String lang = 'ar',
  }) async {
    final response = await apiService.quoteCart(
      body: _body(cart),
      lang: lang,
      xLocale: lang,
    );

    final raw = _decodeBody(response.data);
    final parsed = CartQuoteResponse.fromJson(raw);

    if (raw['success'] == false) {
      throw ServerFailure(
        parsed.message.isEmpty
            ? 'Failed to calculate the cart total.'
            : parsed.message,
      );
    }

    if (parsed.data == null) {
      throw ServerFailure(
        parsed.message.isEmpty ? 'Empty response from server.' : parsed.message,
      );
    }

    return parsed;
  }

  Map<String, dynamic> _body(Cart cart) {
    return {
      'type': cart.orderType,
      'lines': [
        for (final line in cart.lines)
          if (line.item.id != null)
            {
              'item_id': line.item.id,
              'option_id': line.option?.id,
              'addons': [
                for (final addon in line.addons)
                  if (addon.id != null) addon.id,
              ],
              // The quote API treats the quantity of a weight-priced dish as
              // kilos, so `0.25 kg x 2` is sent as `0.5`.
              'quantity': line.item.soldByWeight
                  ? line.weight * line.quantity
                  : line.quantity,
              'note': line.hasNotes ? line.notes.trim() : null,
            },
      ],
    };
  }

  Map<String, dynamic> _decodeBody(dynamic body) {
    final Map<String, dynamic>? raw;
    if (body is Map<String, dynamic>) {
      raw = body;
    } else if (body is Map) {
      raw = Map<String, dynamic>.from(body);
    } else if (body is String && body.trim().isNotEmpty) {
      raw = _asMap(jsonDecode(body));
    } else {
      raw = null;
    }

    if (raw == null) {
      throw ServerFailure('Empty response from server.');
    }

    return raw;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
